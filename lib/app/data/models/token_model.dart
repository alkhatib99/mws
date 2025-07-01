class Token {
  final String name;
  final String symbol;
  final String? contractAddress; // null for native tokens like ETH, BNB
  final String logoPath;
  final int decimals;

  Token({
    required this.name,
    required this.symbol,
    this.contractAddress,
    required this.logoPath,
    this.decimals = 18,
  });

  bool get isNative => contractAddress == null;
}

