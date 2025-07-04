import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart';
import 'package:web3dart/credentials.dart'; // For EthereumAddress, EthPrivateKey
import 'dart:js' as js;
import 'dart:js_util' as js_util;

class Web3Service {
  late Web3Client _web3client;
  String? connectedWebAddress;
  bool _isConnected = false;

  void initialize(String rpcUrl) {
    _web3client = Web3Client(rpcUrl, Client());
  }

  // MetaMask (Web3) related methods
  bool get isWeb3Available {
    try {
      return js.context.hasProperty('ethereum');
    } catch (e) {
      return false;
    }
  }

  bool get isConnected => _isConnected && connectedWebAddress != null;

  Future<bool> connectWebWallet() async {
    try {
      if (!isWeb3Available) {
        print('MetaMask not detected');
        return false;
      }

      final ethereum = js.context['ethereum'];
      if (ethereum == null) {
        return false;
      }

      final accounts = await js_util.promiseToFuture(
        js_util.callMethod(ethereum, 'request', [
          js_util.jsify({'method': 'eth_requestAccounts'})
        ])
      );

      if (accounts != null && accounts.length > 0) {
        connectedWebAddress = accounts[0];
        _isConnected = true;
        print('Connected to MetaMask: $connectedWebAddress');
        return true;
      }

      return false;
    } catch (e) {
      print('Error connecting to MetaMask: $e');
      _isConnected = false;
      connectedWebAddress = null;
      return false;
    }
  }

  Future<double?> getWebWalletBalance() async {
    try {
      if (!isConnected || connectedWebAddress == null) {
        return null;
      }

      final address = EthereumAddress.fromHex(connectedWebAddress!);
      final balance = await getBalance(address);
      return balance.getInEther.toDouble();
    } catch (e) {
      print('Error getting web wallet balance: $e');
      return null;
    }
  }

  // General Web3 methods
  Future<EtherAmount> getBalance(EthereumAddress address) async {
    return await _web3client.getBalance(address);
  }

  Future<EtherAmount> getTokenBalance(EthereumAddress tokenContractAddress, EthereumAddress ownerAddress) async {
    final contract = DeployedContract(
      ContractAbi.fromJson(
        '[{"constant":true,"inputs":[{"name":"_owner","type":"address"}],"name":"balanceOf","outputs":[{"name":"balance","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"}]',
        'ERC20',
      ),
      tokenContractAddress,
    );
    final balanceOf = contract.function("balanceOf");
    final result = await _web3client.call(
      contract: contract,
      function: balanceOf,
      params: [ownerAddress],
    );
    return EtherAmount.fromUnitAndValue(EtherUnit.wei, result[0] as BigInt);
  }

  Future<String> sendTransaction({
    required String privateKey,
    required String recipientAddress,
    required EtherAmount amount,
    required int chainId,
    EtherAmount? gasPrice,
  }) async {
    final credentials = EthPrivateKey.fromHex(privateKey);
    final transaction = Transaction(
      to: EthereumAddress.fromHex(recipientAddress),
      value: amount,
      gasPrice: gasPrice,
      maxGas: 100000, // Default gas limit, can be estimated dynamically
    );
    final txHash = await _web3client.sendTransaction(credentials, transaction, chainId: chainId);
    return txHash;
  }

  Future<EtherAmount> getGasPrice() async {
    return await _web3client.getGasPrice();
  }

  // Private key methods
  bool isValidPrivateKey(String privateKey) {
    try {
      EthPrivateKey.fromHex(privateKey);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<String?> getAddressFromPrivateKey(String privateKey) async {
    try {
      final credentials = EthPrivateKey.fromHex(privateKey);
      final address = credentials.address;
      return address.toString();
    } catch (e) {
      print('Error getting address from private key: $e');
      return null;
    }
  }

  void disconnect() {
    _isConnected = false;
    connectedWebAddress = null;
  }
}


