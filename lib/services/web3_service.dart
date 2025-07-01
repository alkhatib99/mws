import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart';

class Web3Service {
  late Web3Client _web3client;
  String? connectedWebAddress;

  void initialize(String rpcUrl) {
    _web3client = Web3Client(rpcUrl, Client());
  }

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
    return EtherAmount.fromUnitAndValue(EtherUnit.wei, result[0]);
  }

  // Web wallet methods
  bool get isWeb3Available {
    // In a real implementation, this would check for window.ethereum
    return false; // Placeholder for web3 availability check
  }

  Future<bool> connectWebWallet() async {
    // Placeholder for web wallet connection
    return false;
  }

  Future<double> getWebWalletBalance() async {
    // Placeholder for web wallet balance
    return 0.0;
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

  Future<String> getAddressFromPrivateKey(String privateKey) async {
    try {
      final credentials = EthPrivateKey.fromHex(privateKey);
      final address = await credentials.extractAddress();
      return address.hex;
    } catch (e) {
      throw Exception('Invalid private key');
    }
  }
}


