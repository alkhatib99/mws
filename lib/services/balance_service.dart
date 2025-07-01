import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:web3dart/web3dart.dart';
import '../../app/data/models/token_model.dart';
import '../../app/data/models/network_model.dart';

class BalanceService {
  static const Map<String, String> _rpcUrls = {
    'Base': 'https://mainnet.base.org',
    'Ethereum': 'https://eth.llamarpc.com',
    'BNB Chain': 'https://bsc-dataseed.binance.org',
  };

  static const Map<String, Map<String, String>> _tokenContracts = {
    'Base': {
      'USDC': '0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913',
      'USDT': '0xfde4C96c8593536E31F229EA8f37b2ADa2699bb2',
      'DAI': '0x50c5725949A6F0c72E6C4a641F24049A917DB0Cb',
    },
    'Ethereum': {
      'USDC': '0xA0b86a33E6441b8C4505B4afDcA7FBf074497C23',
      'USDT': '0xdAC17F958D2ee523a2206206994597C13D831ec7',
      'DAI': '0x6B175474E89094C44Da98b954EedeAC495271d0F',
    },
    'BNB Chain': {
      'USDC': '0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d',
      'USDT': '0x55d398326f99059fF775485246999027B3197955',
      'DAI': '0x1AF3F329e8BE154074D8769D1FFa4eE058B1DBc3',
      'CAKE': '0x0E09FaBB73Bd3Ade0a17ECC321fD13a19e81cE82',
    },
  };

  static const String _erc20Abi = '''[
    {
      "constant": true,
      "inputs": [{"name": "_owner", "type": "address"}],
      "name": "balanceOf",
      "outputs": [{"name": "balance", "type": "uint256"}],
      "type": "function"
    },
    {
      "constant": true,
      "inputs": [],
      "name": "decimals",
      "outputs": [{"name": "", "type": "uint8"}],
      "type": "function"
    }
  ]''';

  /// Fetch native token balance (ETH, BNB)
  static Future<double> getNativeBalance(
      String walletAddress, String networkName) async {
    try {
      final rpcUrl = _rpcUrls[networkName];
      if (rpcUrl == null) throw Exception('Unsupported network: $networkName');

      final web3Client = Web3Client(rpcUrl, http.Client());
      final address = EthereumAddress.fromHex(walletAddress);
      final balance = await web3Client.getBalance(address);

      web3Client.dispose();
      return balance.getInEther.toDouble();
    } catch (e) {
      print('Error fetching native balance: $e');
      return 0.0;
    }
  }

  /// Fetch ERC20 token balance
  static Future<double> getTokenBalance(
      String walletAddress, String tokenSymbol, String networkName) async {
    try {
      final rpcUrl = _rpcUrls[networkName];
      final contractAddress = _tokenContracts[networkName]?[tokenSymbol];

      if (rpcUrl == null || contractAddress == null) {
        throw Exception('Unsupported token or network');
      }

      final web3Client = Web3Client(rpcUrl, http.Client());
      final contract = DeployedContract(
        ContractAbi.fromJson(_erc20Abi, 'ERC20'),
        EthereumAddress.fromHex(contractAddress),
      );

      final balanceFunction = contract.function('balanceOf');
      final decimalsFunction = contract.function('decimals');

      // Get balance and decimals
      final balanceResult = await web3Client.call(
        contract: contract,
        function: balanceFunction,
        params: [EthereumAddress.fromHex(walletAddress)],
      );

      final decimalsResult = await web3Client.call(
        contract: contract,
        function: decimalsFunction,
        params: [],
      );

      final balance = balanceResult.first as BigInt;
      final decimals = decimalsResult.first as BigInt;

      web3Client.dispose();

      // Convert balance to human readable format
      final divisor = BigInt.from(10).pow(decimals.toInt());
      final balanceDouble = balance.toDouble() / divisor.toDouble();
      return balanceDouble;
    } catch (e) {
      print('Error fetching token balance for $tokenSymbol: $e');
      return 0.0;
    }
  }

  /// Fetch all token balances for a wallet on a specific network
  static Future<Map<String, double>> getAllTokenBalances(
      String walletAddress, String networkName, List<Token> tokens) async {
    final Map<String, double> balances = {};

    try {
      // Fetch native token balance first
      final nativeSymbol = _getNativeTokenSymbol(networkName);
      balances[nativeSymbol] =
          await getNativeBalance(walletAddress, networkName);

      // Fetch ERC20 token balances
      for (final token in tokens) {
        if (token.symbol != nativeSymbol && token.contractAddress!.isNotEmpty) {
          balances[token.symbol] =
              await getTokenBalance(walletAddress, token.symbol, networkName);
        }
      }
    } catch (e) {
      print('Error fetching all token balances: $e');
    }

    return balances;
  }

  /// Get native token symbol for a network
  static String _getNativeTokenSymbol(String networkName) {
    switch (networkName) {
      case 'Base':
      case 'Ethereum':
        return 'ETH';
      case 'BNB Chain':
        return 'BNB';
      default:
        return 'ETH';
    }
  }

  /// Validate wallet address format
  static bool isValidAddress(String address) {
    try {
      EthereumAddress.fromHex(address);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Format balance for display
  static String formatBalance(double balance, {int decimals = 6}) {
    if (balance == 0) return '0.0';

    // For very small amounts, show more decimals
    if (balance < 0.001) {
      return balance.toStringAsFixed(8);
    }

    // For normal amounts, show up to specified decimals
    return balance
        .toStringAsFixed(decimals)
        .replaceAll(RegExp(r'0*$'), '')
        .replaceAll(RegExp(r'\.$'), '');
  }
}
