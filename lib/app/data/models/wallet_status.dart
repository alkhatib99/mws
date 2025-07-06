// models/wallet_status.dart

enum WalletStatus {
  disconnected,
  connecting,
  connected,
}

enum WalletType {
  metamask,
  walletconnect,
  privatekey,
  none,
}