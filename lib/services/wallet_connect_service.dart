import 'dart:async';
import 'dart:math';

class WalletConnectService {
  static final WalletConnectService _instance = WalletConnectService._internal();
  factory WalletConnectService() => _instance;
  WalletConnectService._internal();

  // Connection state
  bool _isConnected = false;
  String? _connectedAddress;
  String? _connectedWalletName;
  String? _sessionTopic;

  // Callbacks
  Function(String address, String walletName)? onSessionEstablished;
  Function()? onSessionDisconnected;
  Function(String error)? onConnectionError;

  // Getters
  bool get isConnected => _isConnected;
  String? get connectedAddress => _connectedAddress;
  String? get connectedWalletName => _connectedWalletName;

  /// Initialize WalletConnect with project ID
  Future<void> initialize({required String projectId}) async {
    try {
      print('WalletConnect initialized with project ID: $projectId');
      // In a real implementation, this would initialize the WalletConnect SDK
    } catch (e) {
      print('Error initializing WalletConnect: $e');
      onConnectionError?.call('Failed to initialize WalletConnect: $e');
    }
  }

  /// Create a pairing URI for mobile wallet connection
  Future<String?> createPairingUri({
    required List<String> chains,
    required Map<String, dynamic> methods,
  }) async {
    try {
      // Simulate creating a pairing URI
      final uri = 'wc:${_generateRandomString(64)}@2?relay-protocol=irn&symKey=${_generateRandomString(64)}';
      print('Generated pairing URI: $uri');
      return uri;
    } catch (e) {
      print('Error creating pairing URI: $e');
      onConnectionError?.call('Failed to create pairing URI: $e');
      return null;
    }
  }

  /// Connect to a wallet using WalletConnect
  Future<bool> connectWallet({
    required String walletName,
    List<String> chains = const ['eip155:1', 'eip155:56', 'eip155:8453'], // Ethereum, BSC, Base
  }) async {
    try {
      print('Attempting to connect to $walletName via WalletConnect...');

      // Simulate connection process
      await Future.delayed(const Duration(seconds: 2));

      // For demonstration, simulate successful connection with random address
      final addresses = [
        '0x742d35Cc6634C0532925a3b8D4C2C4e4C4C4C4C4',
        '0x8ba1f109551bD432803012645Hac136c22C4C4C4',
        '0x1234567890123456789012345678901234567890',
        '0xabcdefabcdefabcdefabcdefabcdefabcdefabcd',
      ];
      
      final randomAddress = addresses[Random().nextInt(addresses.length)];
      
      _isConnected = true;
      _connectedAddress = randomAddress;
      _connectedWalletName = walletName;
      _sessionTopic = _generateRandomString(32);

      print('Successfully connected to $walletName: $randomAddress');
      onSessionEstablished?.call(randomAddress, walletName);
      
      return true;
    } catch (e) {
      print('Error connecting to wallet: $e');
      onConnectionError?.call('Failed to connect to $walletName: $e');
      return false;
    }
  }

  /// Disconnect the current session
  Future<void> disconnect() async {
    try {
      if (_isConnected && _sessionTopic != null) {
        print('Disconnecting WalletConnect session: $_sessionTopic');
        
        // Simulate disconnection
        await Future.delayed(const Duration(milliseconds: 500));
        
        _isConnected = false;
        _connectedAddress = null;
        _connectedWalletName = null;
        _sessionTopic = null;

        print('WalletConnect session disconnected');
        onSessionDisconnected?.call();
      }
    } catch (e) {
      print('Error disconnecting WalletConnect: $e');
      onConnectionError?.call('Failed to disconnect: $e');
    }
  }

  /// Send a transaction request to the connected wallet
  Future<String?> sendTransaction({
    required String to,
    required String value,
    String? data,
    String? gasLimit,
    String? gasPrice,
  }) async {
    try {
      if (!_isConnected) {
        throw Exception('No wallet connected');
      }

      print('Sending transaction request to $_connectedWalletName...');
      
      // Simulate transaction request
      await Future.delayed(const Duration(seconds: 3));
      
      // For demonstration, simulate successful transaction
      final txHash = '0x${_generateRandomString(64)}';
      print('Transaction sent successfully: $txHash');
      
      return txHash;
    } catch (e) {
      print('Error sending transaction: $e');
      onConnectionError?.call('Failed to send transaction: $e');
      return null;
    }
  }

  /// Sign a message with the connected wallet
  Future<String?> signMessage({required String message}) async {
    try {
      if (!_isConnected) {
        throw Exception('No wallet connected');
      }

      print('Requesting message signature from $_connectedWalletName...');
      
      // Simulate signing request
      await Future.delayed(const Duration(seconds: 2));
      
      // For demonstration, simulate successful signing
      final signature = '0x${_generateRandomString(130)}';
      print('Message signed successfully');
      
      return signature;
    } catch (e) {
      print('Error signing message: $e');
      onConnectionError?.call('Failed to sign message: $e');
      return null;
    }
  }

  /// Get account balance (simulated)
  Future<double?> getBalance() async {
    try {
      if (!_isConnected) {
        return null;
      }

      // Simulate balance retrieval
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Return random balance for demonstration
      final balance = (Random().nextDouble() * 10).toDouble();
      return double.parse(balance.toStringAsFixed(4));
    } catch (e) {
      print('Error getting balance: $e');
      return null;
    }
  }

  /// Switch to a different network
  Future<bool> switchNetwork({required String chainId}) async {
    try {
      if (!_isConnected) {
        throw Exception('No wallet connected');
      }

      print('Requesting network switch to chain $chainId...');
      
      // Simulate network switch request
      await Future.delayed(const Duration(seconds: 1));
      
      print('Network switched successfully to chain $chainId');
      return true;
    } catch (e) {
      print('Error switching network: $e');
      onConnectionError?.call('Failed to switch network: $e');
      return false;
    }
  }

  /// Generate a random string for simulation purposes
  String _generateRandomString(int length) {
    const chars = '0123456789abcdef';
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(length, (_) => chars.codeUnitAt(random.nextInt(chars.length)))
    );
  }

  /// Get supported wallets for WalletConnect
  List<Map<String, dynamic>> getSupportedWallets() {
    return [
      {
        'name': 'MetaMask',
        'id': 'metamask',
        'icon': 'assets/images/metamask_logo.png',
        'description': 'Connect via MetaMask mobile app',
        'deepLink': 'https://metamask.app.link/wc',
        'mobile': true,
        'desktop': false,
      },
      {
        'name': 'Trust Wallet',
        'id': 'trust',
        'icon': 'assets/images/trustwallet_logo.png',
        'description': 'Connect via Trust Wallet mobile app',
        'deepLink': 'https://link.trustwallet.com/wc',
        'mobile': true,
        'desktop': false,
      },
      {
        'name': 'Coinbase Wallet',
        'id': 'coinbase',
        'icon': 'assets/images/coinbase_logo.png',
        'description': 'Connect via Coinbase Wallet mobile app',
        'deepLink': 'https://go.cb-w.com/wc',
        'mobile': true,
        'desktop': false,
      },
      {
        'name': 'Rainbow',
        'id': 'rainbow',
        'icon': 'assets/images/rainbow_logo.png',
        'description': 'Connect via Rainbow mobile app',
        'deepLink': 'https://rnbwapp.com/wc',
        'mobile': true,
        'desktop': false,
      },
      {
        'name': 'Ledger Live',
        'id': 'ledger',
        'icon': 'assets/images/ledger_logo.png',
        'description': 'Connect via Ledger Live mobile app',
        'deepLink': 'ledgerlive://wc',
        'mobile': true,
        'desktop': true,
      },
      {
        'name': 'Phantom',
        'id': 'phantom',
        'icon': 'assets/images/phantom_logo.png',
        'description': 'Connect via Phantom (Solana)',
        'deepLink': 'https://phantom.app/ul/v1/connect',
        'mobile': true,
        'desktop': true,
      },
    ];
  }
}

