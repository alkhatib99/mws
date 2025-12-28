class AppConstants {
  // Asset paths
  static const String bagLogoPath = 'assets/images/logo.png';
  static const String metamaskLogoPath = 'assets/images/metamask_logo.png';
  static const String walletConnectLogoPath =
      'assets/images/walletconnect_logo.png';
  static const String trustWalletLogoPath =
      'assets/images/trustwallet_logo.png';

  static const String coinbaseLogoPath = 'assets/images/coinbase_logo.png';
  static const String rainbowLogoPath = 'assets/images/rainbow_logo.png';
  static const String ledgerLogoPath = 'assets/images/ledger_logo.png';
  static const String phantomLogoPath = 'assets/images/phantom_logo.png';
  static const String otherWalletsIconPath =
      'assets/images/other_wallets_icon.png';
  static const REOWN_APP_NAME = "mws";
  static const String REOWN_PROJECT_ID = "c828aec3b3a8cdbc7a2fbf0ffe3be04a";
  static const String REOWN_APP_ICON =
      'https://raw.githubusercontent.com/aboodkhatib/mws/main/assets/images/logo.png';
  static const String REOWN_APP_DESCRIPTION =
      'Multi Wallet Sender - Send crypto to multiple addresses at once';
  static const String REOWN_APP_URL = 'https://alkhatibcrypto.xyz';
  // App info
  static const String appName = 'BAG MWS DApp';
  static const String appTitle = 'BAG MWS DApp';
  static const String appVersion = '1.0.0';
  static const String copyright = '© 2023 MWS. All rights reserved.';

  // Deployment domain
  static const String deploymentDomain = 'alkhatibcrypto.xyz';

  // Breakpoints for responsive design
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1024;

  // Animation durations
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(milliseconds: 800);
  static const Duration shortAnimationDuration = Duration(milliseconds: 150);

  // Network configurations
  static const Map<String, Map<String, dynamic>> networks = {
    'Ethereum': {
      'rpc': 'https://mainnet.infura.io/v3/YOUR_INFURA_KEY ',
      'chainId': 1,
      'currency': 'ETH',
      'explorer': 'https://etherscan.io/tx/ ',
      'nativeCurrencySymbol': 'ETH',
      'rpcUrls': ['https://mainnet.infura.io/v3/YOUR_INFURA_KEY '],
      'blockExplorerUrls': ['https://etherscan.io '],
    },
    'Base': {
      'rpc': 'https://mainnet.base.org ',
      'chainId': 8453,
      'currency': 'ETH',
      'explorer': 'https://basescan.org/tx/ ',
      'nativeCurrencySymbol': 'ETH',
      'rpcUrls': ['https://mainnet.base.org '],
      'blockExplorerUrls': ['https://basescan.org '],
    },
    'BNB Chain': {
      'rpc': 'https://bsc-dataseed.binance.org/',
      'chainId': 56,
      'explorer': 'https://bscscan.com/tx/',
      'currency': 'BNB',
    },
    'Polygon': {
      'rpc': 'https://polygon-rpc.com/',
      'chainId': 137,
      'explorer': 'https://polygonscan.com/tx/',
      'currency': 'MATIC',
    },
    'Arbitrum': {
      'rpc': 'https://arb1.arbitrum.io/rpc',
      'chainId': 42161,
      'explorer': 'https://arbiscan.io/tx/',
      'currency': 'ETH',
    },
  };
  static const List<String> supportedNetworks = [
    'Ethereum',
    'Base',
    'BNB Chain',
    'Polygon',
    'Arbitrum',
  ];
  //  wallets  = [
  //   'MetaMask',
  //   'WalletConnect',
  //   'Trust Wallet',
  //   'Coinbase Wallet',
  //   // 'Rainbow Wallet',
  //   // 'Ledger',
  //   'Phantom Wallet',
  // ];
  // Arabic content
  static const String arabicFooterText =
      'هذا البرنامج أحد الأدوات المستخدمة في المجتمع العربي الأكبر في الويب3 BAG\n'
      'This tool is part of the tools used in the largest Arabic Web3 community – BAG';
}
