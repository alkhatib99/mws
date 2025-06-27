# Web3 Multi Wallet Sender

A Flutter Web App for sending cryptocurrency to multiple wallet addresses simultaneously. This tool is part of the BAG (Blockchain Arab Guild) community ecosystem.

## Features

- **Multi-Network Support**: Base, Ethereum, BNB Chain, and custom networks
- **Batch Transactions**: Send to multiple addresses in one operation
- **File Upload**: Load recipient addresses from .txt files
- **Responsive Design**: Works on desktop, tablet, and mobile devices
- **Dark Theme**: Professional dark UI matching BAG community branding
- **Transaction Tracking**: View transaction links with direct explorer access
- **Custom Networks**: Add your own blockchain networks

## Technology Stack

- **Flutter**: Cross-platform UI framework
- **GetX**: State management and routing
- **web3dart**: Ethereum blockchain interaction (placeholder implementation)
- **file_picker**: File upload functionality
- **url_launcher**: External link handling

## Project Structure

```
lib/
├── controllers/
│   └── wallet_controller.dart      # GetX controller for state management
├── views/
│   ├── splash_screen.dart          # Animated splash screen
│   └── home_screen.dart            # Main wallet sender interface
├── widgets/
│   ├── custom_text_field.dart      # Reusable input field
│   ├── network_dropdown.dart       # Network selection dropdown
│   ├── send_button.dart            # Send funds button with loading state
│   ├── tx_output_list.dart         # Transaction results display
│   └── social_links_bar.dart       # BAG community links
├── themes/
│   └── app_theme.dart              # Dark theme configuration
├── routes/
│   └── app_routes.dart             # Navigation routes
├── services/
│   └── web3_service.dart           # Web3 integration (placeholder)
└── main.dart                       # App entry point
```

## Getting Started

### Prerequisites

- Flutter SDK (3.0.0 or higher)
- Web browser for testing
- Text editor or IDE (VS Code, Android Studio)

### Installation

1. Clone or download the project files
2. Navigate to the project directory
3. Install dependencies:
   ```bash
   flutter pub get
   ```

### Running the App

For web development:
```bash
flutter run -d chrome
```

For building web release:
```bash
flutter build web
```

## Configuration

### Adding Custom Networks

The app supports adding custom blockchain networks through the UI:

1. Click "Add Custom Network" button
2. Enter network details:
   - Network Name
   - RPC URL
   - Chain ID
   - Explorer URL (optional)

### Web3 Integration

Currently, the app uses placeholder implementations for Web3 functionality. To enable real blockchain transactions:

1. Uncomment Web3 imports in `lib/services/web3_service.dart`
2. Replace placeholder methods with actual Web3 implementations
3. Add proper error handling and security measures
4. Test thoroughly on testnets before mainnet use

## Security Considerations

⚠️ **Important Security Notes:**

- Never expose private keys in production
- Always validate user inputs
- Use secure storage for sensitive data
- Test on testnets before mainnet deployment
- Implement proper error handling
- Consider using hardware wallets for production

## UI Components

### Theme Colors

- **Primary Background**: `#1E1E2F`
- **Primary Green**: `#28A745` (Send button)
- **Primary Blue**: `#007ACC` (Secondary actions)
- **Neutral Gray**: `#44475A` (Neutral buttons)
- **Light Background**: `#F0F0F0` (Input fields)

### Responsive Design

The app adapts to different screen sizes:
- **Desktop**: Full-width layout (max 720px)
- **Tablet**: Responsive padding and spacing
- **Mobile**: Optimized touch targets and layout

## File Upload Format

The app accepts `.txt` files with wallet addresses:
```
0x1234567890123456789012345678901234567890
0xabcdefabcdefabcdefabcdefabcdefabcdefabcd
0x9876543210987654321098765432109876543210
```

Each address should be on a separate line.

## BAG Community

This tool is part of the BAG (Blockchain Arab Guild) ecosystem:

- **Website**: [bagguild.com](https://bagguild.com/)
- **dApp**: [dapp.bagguild.com](https://dapp.bagguild.com/)
- **Discord**: [discord.gg/bagguild](https://discord.gg/bagguild)
- **Twitter**: [@BagGuild](https://twitter.com/BagGuild)

## Development Roadmap

- [ ] Real Web3 integration with web3dart
- [ ] Hardware wallet support
- [ ] Transaction history
- [ ] Gas optimization
- [ ] Multi-token support (ERC-20)
- [ ] Batch transaction optimization
- [ ] Advanced security features

## Contributing

Contributions are welcome! Please ensure:

1. Code follows Flutter best practices
2. UI maintains BAG community branding
3. Security considerations are addressed
4. Tests are included for new features

## License

This project is part of the BAG community tools. Please respect the community guidelines and use responsibly.

## Disclaimer

This tool is for educational and community purposes. Users are responsible for:
- Securing their private keys
- Verifying transaction details
- Understanding blockchain risks
- Complying with local regulations

Always test on testnets before using real funds.

