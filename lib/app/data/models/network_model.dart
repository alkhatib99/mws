import 'token_model.dart';

class Network {
  final String name;
  final String rpcUrl;
  final int chainId;
  final String explorerUrl;
  final String currency;
  final String logoPath;
  final List<Token> supportedTokens;

  Network({
    required this.name,
    required this.rpcUrl,
    required this.chainId,
    required this.explorerUrl,
    required this.currency,
    required this.logoPath,
    required this.supportedTokens,
  });
}


