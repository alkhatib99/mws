import 'dart:async';
import 'dart:math';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart';
import 'package:web3dart/credentials.dart';
import 'package:mws/app/data/models/token_model.dart';

class BalanceService {
  static final Web3Client _web3client = Web3Client(
      'https://mainnet.infura.io/v3/YOUR_INFURA_KEY', Client()); // Replace with your Infura key

  static Future<Map<String, double>> getAllTokenBalances(
      String walletAddress, String networkName, List<Token> supportedTokens)
  async {
    final Map<String, double> balances = {};
    final EthereumAddress address = EthereumAddress.fromHex(walletAddress);

    for (final token in supportedTokens) {
      if (token.symbol == 'ETH' || token.symbol == 'BNB') {
        // Fetch native token balance
        final etherAmount = await _web3client.getBalance(address);
        balances[token.symbol] = etherAmount.getInEther.toDouble();
      } else {
        // Fetch ERC-20 token balance
        try {
          final contract = DeployedContract(
            ContractAbi.fromJson(
                '[{"constant":true,"inputs":[{"name":"_owner","type":"address"}],"name":"balanceOf","outputs":[{"name":"balance","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"}]',
                token.contractAddress!),
            EthereumAddress.fromHex(token.contractAddress!),
          );
          final balanceOf = contract.function('balanceOf');
          final result = await _web3client.call(
            contract: contract,
            function: balanceOf,
            params: [address],
          );
          final balance = (result[0] as BigInt).toDouble() / pow(10, token.decimals);
          balances[token.symbol] = balance;
        } catch (e) {
          print('Error fetching ${token.symbol} balance: $e');
          balances[token.symbol] = 0.0;
        }
      }
    }
    return balances;
  }

  static String formatBalance(double balance, {int decimals = 4}) {
    return balance.toStringAsFixed(decimals);
  }

  static bool isValidAddress(String address) {
    try {
      EthereumAddress.fromHex(address);
      return true;
    } catch (_) {
      return false;
    }
  }
}


