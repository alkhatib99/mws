class WalletModel {
  final String name;
  final String iconPath;
  final String description;
  final bool isAvailable;
  final bool isConnecting;

  WalletModel({
    required this.name,
    required this.iconPath,
    required this.description,
    required this.isAvailable,
    this.isConnecting = false,
  });
}
