
# 🚀 Multi Wallet Sender (MWS) - Decentralized Application

A professional-grade **decentralized application (DApp)** for connecting cryptocurrency wallets and sending crypto to multiple addresses simultaneously. Built with Flutter Web and designed with inspiration from [bagguild.com](https://bagguild.com) and [dapp.bagguild.com](https://dapp.bagguild.com).

## 🌟 What Makes This a True DApp

### 🔒 Complete Decentralization

- **No backend servers**: All operations are performed client-side
- **No user data storage**: We never store or access your personal information
- **No central database**: No centralized data collection or storage
- **Wallet-based authentication only**: Authentication through blockchain wallets

### 🛡️ Privacy & Security Guarantees

- **Private keys never leave your device**: Your keys remain secure in your wallet
- **No data tracking**: We don't track user behavior or transaction patterns
- **Direct blockchain interaction**: Transactions go directly to the blockchain
- **Open source transparency**: All code is available for audit

## 🎨 Design Inspiration

This application draws design inspiration from the BAG Guild ecosystem:

- **Visual Style**: Inspired by [bagguild.com](https://bagguild.com)
- **Interactive Elements**: Based on [dapp.bagguild.com](https://dapp.bagguild.com)
- **Color Palette**: Modern dark theme with purple accents
- **Typography**: Montserrat font family for consistency
- **Animations**: Subtle hover effects and smooth transitions

## 🛠️ Tech Stack

### Frontend Framework

- **Flutter + GetX**: Cross-platform framework with reactive state management
- **Web3Dart**: Ethereum blockchain interaction library
- **WalletConnect**: Protocol for connecting mobile wallets

### Blockchain Integration

- **Direct Web3 Integration**: No proxy servers or intermediaries
- **Multi-network Support**: Ethereum, Base, Polygon, Arbitrum
- **Real-time Balance Fetching**: Live wallet balance updates
- **Gas Fee Optimization**: Smart gas estimation and optimization

### UI/UX Technologies

- **Responsive Design**: Optimized for desktop, tablet, and mobile
- **Glassmorphism**: Modern glass-like UI effects
- **Smooth Animations**: 60fps animations and transitions
- **Accessibility**: WCAG compliant design patterns

## 🌟 Features

### 💼 Wallet Connections

- **MetaMask Integration**: Real browser extension connection with balance retrieval
- **WalletConnect Support**: Mobile wallet pairing with QR code scanning
- **Private Key Import**: Secure private key input with validation
- **Multi-Wallet Support**: MetaMask, Trust Wallet, Coinbase, Rainbow, Ledger, Phantom

### 🎨 User Experience

- **Fully Responsive**: Optimized for desktop, tablet, and mobile devices
- **Modern UI**: Glassmorphism design with smooth animations
- **Bilingual Support**: Arabic and English content
- **Real-time Feedback**: Loading states and error handling

### 🔧 Technical Excellence

- **Modular Architecture**: Clean, maintainable code structure
- **State Management**: GetX for reactive UI updates
- **Performance Optimized**: Efficient rendering and memory management
- **Production Ready**: Comprehensive error handling and validation

## 🚀 Quick Start

### Prerequisites

- Flutter SDK (3.0+)
- Chrome browser with MetaMask extension
- Git

### Installation

1. **Clone the repository**

   ```bash
   git clone https://github.com/alkhatib99/mws.git
   cd mws
   ```
2. **Install dependencies**

   ```bash
   flutter pub get
   ```
3. **Run the application**

   ```bash
   flutter run -d chrome
   ```
4. **Install MetaMask** (if not already installed)

   - Visit [Chrome Web Store](https://chrome.google.com/webstore/detail/metamask/nkbihfbeogaeaoehlefnkodbefgpgknn)
   - Add MetaMask to Chrome
   - Set up your wallet (import existing or create new)
   - Connect to your preferred network

## 📱 Usage

### Connecting Your Wallet

#### Option 1: Browser Extension (MetaMask)

1. Click on the MetaMask wallet card
2. Approve the connection in your MetaMask extension
3. Your wallet address and balance will be displayed
4. Navigate to the multi-send interface

#### Option 2: WalletConnect (Mobile Wallets)

1. Click on the WalletConnect option
2. Select your preferred mobile wallet from the modal
3. Scan the QR code with your mobile wallet app
4. Approve the connection on your mobile device

#### Option 3: Private Key Import

1. Scroll to the "Private Key Import" section
2. Enter your private key (64-character hexadecimal)
3. Click "Import Wallet"
4. Your derived address and balance will be shown

### Multi-Send Functionality

*Coming soon - Send crypto to multiple addresses in a single transaction*

## 📚 Documentation

For detailed information about how MWS works as a decentralized application, please read:

- **[How MWS Works](how_mws_works.md)**: Comprehensive guide explaining the decentralized architecture, privacy guarantees, wallet connection process, and transaction handling via Web3 technology.

## 🏗️ Project Structure

```
mws/
├── lib/
│   ├── app/
│   │   ├── controllers/           # State management
│   │   ├── theme/                 # App theming
│   │   ├── views/
│   │   │   ├── widgets/           # Reusable components
│   │   │   └── wallet_connect/    # Wallet connection UI
│   │   └── routes/                # Navigation
│   ├── services/                  # Business logic
│   ├── utils/                     # Utilities and constants
│   └── main.dart                  # App entry point
├── assets/                        # Images and assets
└── web/                          # Web-specific files
```

## 🛠️ Development

### Key Components

#### Controllers

- `WalletConnectController`: Manages wallet connection state and UI interactions

#### Services

- `Web3Service`: Handles blockchain interactions and wallet communications

#### Widgets

- `AnimatedLogo`: Reusable animated logo component
- `GlassCard`: Glassmorphism container with backdrop effects
- `ResponsiveGrid`: Adaptive grid layout for different screen sizes
- `WalletCard`: Individual wallet option display

### State Management

The app uses GetX for reactive state management:

```dart
// Reactive variables
final RxBool isLoading = false.obs;
final RxString connectedAddress = ''.obs;
final RxDouble walletBalance = 0.0.obs;

// UI updates automatically when values change
Obx(() => Text('Balance: ${controller.walletBalance.value} ETH'))
```

### Responsive Design

Custom responsive components adapt to screen size:

```dart
// Automatic font scaling
ResponsiveTitle('Connect Your Wallet')

// Adaptive grid columns
ResponsiveGrid(
  mobileColumns: 1,
  tabletColumns: 2, 
  desktopColumns: 3,
  children: walletCards,
)
```

## 🌐 Deployment

### Production Deployment to alkhatibcrypto.xyz

1. **Build for production**

   ```bash
   flutter build web --release
   ```
2. **Deploy build files**

   - Upload `build/web/` contents to your web server
   - Ensure HTTPS is enabled for Web3 provider access
   - Configure proper CORS headers
3. **Domain configuration**

   - Point `alkhatibcrypto.xyz` to your web server
   - Set up SSL certificate
   - Configure CDN for optimal performance

### Environment Considerations

- **HTTPS Required**: Web3 providers require secure connections
- **CORS Policy**: Configure for wallet extension communication
- **CSP Headers**: Set appropriate Content Security Policy

## 🔧 Configuration

### Supported Networks

```dart
// Available blockchain networks
'Base': {
  'rpc': 'https://mainnet.base.org',
  'chainId': 8453,
  'explorer': 'https://basescan.org/tx/',
},
'Ethereum': {
  'rpc': 'https://mainnet.infura.io/v3/YOUR_INFURA_KEY',
  'chainId': 1,
  'explorer': 'https://etherscan.io/tx/',
},
// ... more networks
```

### Customization

- **Theme Colors**: Modify `app/theme/app_theme.dart`
- **Wallet Options**: Update `wallets` list in controller
- **Responsive Breakpoints**: Adjust in responsive components
- **Multilingual Content**: Edit `utils/constants.dart`

## 🧪 Testing

### Manual Testing Checklist

- [ ] MetaMask connection and balance retrieval
- [ ] Responsive layout on mobile, tablet, desktop
- [ ] Private key validation and import
- [ ] Error handling for invalid inputs
- [ ] Animation performance and smoothness
- [ ] Arabic text rendering and cultural elements

### Browser Testing

- Chrome (recommended for MetaMask)
- Firefox with MetaMask
- Safari (limited Web3 support)
- Mobile browsers (for responsive testing)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🌍 Community

### BAG Guild

This application is part of the tools used in the largest Arabic Web3 community – BAG Guild.

**Arabic**: هذا البرنامج أحد الأدوات المستخدمة في المجتمع العربي الأكبر في الويب3 BAG

### Support

- **Developer**: Abedalqader Alkhatib (@alkhatib99)
- **Website**: [alkhatibcrypto.xyz](https://alkhatibcrypto.xyz)
- **Community**: BAG Guild

## 🔮 Roadmap

### Phase 1: Core Functionality ✅

- [X] Wallet connection interface
- [X] MetaMask integration
- [X] Responsive design
- [X] Private key import

### Phase 2: Multi-Send (In Progress)

- [ ] Multi-address transaction interface
- [ ] CSV import for bulk addresses
- [ ] Transaction preview and confirmation
- [ ] Gas optimization

### Phase 3: Advanced Features

- [ ] Real WalletConnect v2 integration
- [ ] Hardware wallet support (Ledger)
- [ ] Multi-chain support
- [ ] Transaction history

### Phase 4: Enhanced UX

- [ ] Dark/light theme toggle
- [ ] Advanced settings panel
- [ ] Analytics dashboard
- [ ] Mobile app version

---

## 📦 Latest Release

**Version:** [v1.0.0](https://github.com/alkhatib99/mws/releases/tag/v1.0.0)  
Released on: July 1, 2025  
Includes MetaMask support, private key import, Web3 integration, Arabic UI, and full RTL layout.


**Built with ❤️ for the Arabic Web3 Community**
