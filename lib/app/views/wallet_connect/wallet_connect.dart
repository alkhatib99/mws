// // views/wallet_connect/wallet_connect.dart

// import 'dart:async';
// import 'dart:convert';
// import 'dart:html' as html;
// import 'dart:js' as js;

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:web3dart/web3dart.dart';
// import 'package:walletconnect_dart/walletconnect_dart.dart';
// import 'package:crypto/crypto.dart';
// import 'package:pointycastle/export.dart';

// import '../../app/controllers/wallet_controller.dart';
// import '../../services/web3_service.dart';
// import '../../utils/constants.dart';
// import '../../widgets/glass_card.dart';
// import '../../theme/app_theme.dart';

// class WalletConnectScreen extends StatefulWidget {
//   const WalletConnectScreen({Key? key}) : super(key: key);

//   @override
//   _WalletConnectScreenState createState() => _WalletConnectScreenState();
// }

// class _WalletConnectScreenState extends State<WalletConnectScreen> {
//   final WalletController _walletController = Get.find<WalletController>();
//   final Web3Service _web3Service = Get.find<Web3Service>();
  
//   late WalletConnect connector;
//   late SessionStatus _session;
//   bool _isConnecting = false;
//   bool _sessionEstablished = false;
//   Timer? _pollingTimer;
//   String? _uri;
//   String? _qrCodeData;
//   final StreamController<WalletConnectEvent> _eventStreamController = StreamController<WalletConnectEvent>.broadcast();

//   @override
//   void initState() {
//     super.initState();
    
//     // Initialize WalletConnect with default configuration
//     connector = WalletConnect(
//       bridge: 'https://bridge.walletconnect.org ',
//       clientMeta: PeerMeta(
//         name: 'Multi Wallet Sender',
//         description: 'Send crypto to multiple addresses simultaneously',
//         url: 'https://alkhatibcrypto.xyz ',
//         icons: ['https://alkhatibcrypto.xyz/icon-192x192.png '],
//       ),
//       storage: LocalStorage(), // You can implement your own storage if needed
//     );
    
//     _session = connector.session;
    
//     // Set up event listeners
//     connector.on('connect', _handleConnect);
//     connector.on('session_update', _handleSessionUpdate);
//     connector.on('disconnect', _handleDisconnect);
//     connector.on('call_request', _handleCallRequest);
//     connector.on('wc_sessionRequest', _handleRequest);
    
//     _initializeConnection();
//   }

//   Future<void> _initializeConnection() async {
//     if (connector.connected && connector.session.status == SessionStatus.connected) {
//       setState(() {
//         _sessionEstablished = true;
//         _isConnecting = false;
//         _session = connector.session;
//       });
      
//       _startTransactionPolling();
//     }
//   }

//   Future<String> generatePairingUri() async {
//     if (!connector.connected || connector.session.status != SessionStatus.disconnected) {
//       await connector.createSession(
//         chainId: 1, // Default to Ethereum mainnet
//         onDisplayUri: (uri) {
//           setState(() {
//             _uri = uri;
//             _qrCodeData = 'walletconnect:$uri';
//           });
//         },
//       );
//     }
    
//     return _qrCodeData!;
//   }

//   void showQRCode(String uri) {
//     // Create a canvas element for the QR code
//     final canvas = html.CanvasElement(width: 300, height: 300);
//     canvas.id = 'walletconnect-qrcode';
    
//     final container = html.querySelector('#qr-code-container');
//     if (container != null) {
//       container.innerHtml = '';
//       container.append(canvas);
      
//       // Generate QR code using JavaScript interop
//       final context = canvas.getContext('2d') as html.CanvasRenderingContext2D;
//       final qr = js.JsObject(js.context['QRCode'], [
//         canvas,
//         js.JsObject.jsify({
//           'text': uri,
//           'width': 300,
//           'height': 300,
//           'colorDark': '#ffffff',
//           'colorLight': '#000000',
//           'correctLevel': js.context['QRCode.CorrectLevel.H']
//         })
//       ]);
//     }
//   }

//   void _handleConnect(SessionStatus session) {
//     setState(() {
//       _session = session;
//       _sessionEstablished = session.status == SessionStatus.connected;
//       _isConnecting = false;
//     });
    
//     _startTransactionPolling();
    
//     _eventStreamController.add(WalletConnectEvent(
//       type: WalletConnectEventType.connect,
//       session: session,
//     ));
//   }

//   void _handleSessionUpdate(SessionStatus session) {
//     setState(() {
//       _session = session;
//       _sessionEstablished = session.status == SessionStatus.connected;
//     });
    
//     _eventStreamController.add(WalletConnectEvent(
//       type: WalletConnectEventType.sessionUpdate,
//       session: session,
//     ));
//   }

//   void _handleDisconnect([dynamic error]) {
//     setState(() {
//       _isConnecting = false;
//       _sessionEstablished = false;
//     });
    
//     _stopTransactionPolling();
    
//     _eventStreamController.add(WalletConnectEvent(
//       type: WalletConnectEventType.disconnect,
//       errorMessage: error?.toString(),
//     ));
//   }

//   void _handleRequest(dynamic request) {
//     debugPrint("Received request: $request");
    
//     _eventStreamController.add(WalletConnectEvent(
//       type: WalletConnectEventType.request,
//       request: request,
//     ));
//   }

//   void _handleCallRequest(CallRequest call) {
//     debugPrint("Received call request: $call");
    
//     // Handle common methods
//     switch (call.method) {
//       case 'eth_accounts':
//         connector.approveCall(CallResponse(id: call.id, result: [connector.session.accounts.first]));
//         break;
        
//       case 'eth_chainId':
//         connector.approveCall(CallResponse(id: call.id, result: [connector.session.chainId.toString(16)]));
//         break;
        
//       case 'eth_getBalance':
//         // Return mock balance or fetch real one
//         connector.approveCall(CallResponse(id: call.id, result: ['0x0']));
//         break;
        
//       case 'eth_sendTransaction':
//         // Show transaction confirmation dialog
//         _showTransactionConfirmation(call);
//         break;
        
//       default:
//         connector.rejectCall(CallResponse(id: call.id, error: 'Method not supported'));
//     }
    
//     _eventStreamController.add(WalletConnectEvent(
//       type: WalletConnectEventType.callRequest,
//       callRequest: call,
//     ));
//   }

//   void _showTransactionConfirmation(CallRequest call) {
//     final params = jsonDecode(call.params[0]);
    
//     final transaction = Transaction(
//       from: EthereumAddress.fromHex(params['from']),
//       to: EthereumAddress.fromHex(params['to']),
//       value: EtherAmount.fromHex(params['value']),
//       gasPrice: EtherAmount.fromHex(params['gasPrice']),
//       maxGas: int.parse(params['gas'].substring(2), radix: 16),
//     );
    
//     // Show dialog to user for transaction confirmation
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text('Confirm Transaction'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text('From: ${transaction.from.hex}'),
//             Text('To: ${transaction.to?.hex ?? 'Contract Creation'}'),
//             Text('Value: ${EtherConversion.fromWeiToEther(transaction.value.getInWei)} ETH'),
//             Text('Gas Limit: ${transaction.maxGas}'),
//             Text('Gas Price: ${EtherConversion.fromGweiToEther(transaction.gasPrice.getValueInUnit(EtherUnit.gwei))} ETH'),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.pop(context);
//               connector.rejectCall(CallResponse(id: call.id, error: 'User rejected transaction'));
//             },
//             child: Text('Reject'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               Navigator.pop(context);
//               connector.approveCall(CallResponse(id: call.id, result: ['0x1'])); // Dummy tx hash
              
//               // Add to transaction history
//               _web3Service.addTransaction(TransactionInfo(
//                 hash: '0x${generateRandomHash(64)}',
//                 from: transaction.from.hex,
//                 to: transaction.to?.hex ?? '',
//                 value: EtherConversion.fromWeiToEther(transaction.value.getInWei),
//                 status: TransactionStatus.pending,
//                 timestamp: DateTime.now(),
//                 network: 'Ethereum',
//               ));
//             },
//             child: Text('Approve'),
//           ),
//         ],
//       ),
//     );
//   }

//   String generateRandomHash(int length) {
//     final random = Random.secure();
//     final values = List<int>.generate(length, (_) => random.nextInt(16));
//     return HEX.encode(values);
//   }

//   void _startTransactionPolling() {
//     _pollingTimer = Timer.periodic(Duration(seconds: 15), (timer) async {
//       if (_session.status == SessionStatus.connected) {
//         try {
//           // Check for new transactions
//           final pendingTxs = await _getPendingTransactions();
          
//           for (var tx in pendingTxs) {
//             _web3Service.addTransaction(tx);
//           }
//         } catch (e) {
//           debugPrint("Error fetching transactions: $e");
//         }
//       }
//     });
//   }

//   void _stopTransactionPolling() {
//     _pollingTimer?.cancel();
//   }

//   Future<List<TransactionInfo>> _getPendingTransactions() async {
//     // Implement actual transaction fetching logic
//     return [];
//   }

//   Future<void> _approveSession() async {
//     setState(() {
//       _isConnecting = true;
//     });
    
//     try {
//       final accounts = await _web3Service.getAccounts();
//       final chainId = await _web3Service.getChainId();
      
//       connector.approveSession(
//         accounts: accounts.map((acc) => acc.hex).toList(),
//         chainId: chainId,
//       );
      
//       setState(() {
//         _session = connector.session;
//         _sessionEstablished = true;
//         _isConnecting = false;
//       });
      
//       // Start watching for balance updates
//       _startTransactionPolling();
      
//     } catch (e) {
//       debugPrint("Session approval error: $e");
//       setState(() {
//         _isConnecting = false;
//       });
//       _showErrorDialog('Failed to approve session: $e');
//     }
//   }

//   void _rejectSession() {
//     connector.rejectSession(message: 'User rejected connection');
//     setState(() {
//       _isConnecting = false;
//     });
//   }

//   void _killSession() {
//     connector.killSession();
//     setState(() {
//       _sessionEstablished = false;
//       _session = connector.session;
//     });
//   }

//   void _showErrorDialog(String message) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text('Connection Error'),
//         content: Text(message),
//         actions: [
//           TextButton(
//             onPressed: Navigator.of(context).pop,
//             child: Text('OK'),
//           )
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Connect Wallet'),
//         centerTitle: true,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             GlassCard(
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   children: [
//                     Text(
//                       _sessionEstablished ? 'Connected' : 'Scan QR Code',
//                       style: Theme.of(context).textTheme.headline6!.copyWith(color: Colors.white),
//                       textAlign: TextAlign.center,
//                     ),
//                     SizedBox(height: 16),
//                     if (!_sessionEstablished)
//                       Container(
//                         width: 300,
//                         height: 300,
//                         decoration: BoxDecoration(
//                           color: Colors.black.withOpacity(0.3),
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: Center(
//                           child: _uri == null
//                               ? CircularProgressIndicator()
//                               : Container(
//                                   width: 280,
//                                   height: 280,
//                                   child: QrImage(
//                                     data: _qrCodeData!,
//                                     size: Size(280, 280),
//                                     gapless: false,
//                                   ),
//                                 ),
//                         ),
//                       ),
//                     SizedBox(height: 16),
//                     if (_sessionEstablished)
//                       Text(
//                         'Connected to ${_session.accounts.first}',
//                         style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.white70),
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     SizedBox(height: 16),
//                     if (_sessionEstablished)
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           ElevatedButton.icon(
//                             onPressed: _killSession,
//                             icon: Icon(Icons.power_settings_new),
//                             label: Text('Disconnect'),
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: AppTheme.colors.primary.withOpacity(0.8),
//                             ),
//                           ),
//                         ],
//                       ),
//                     if (!_sessionEstablished)
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           ElevatedButton.icon(
//                             onPressed: _isConnecting ? null : _approveSession,
//                             icon: Icon(Icons.check),
//                             label: Text('Approve Connection'),
//                           ),
//                           SizedBox(width: 8),
//                           TextButton.icon(
//                             onPressed: _rejectSession,
//                             icon: Icon(Icons.close),
//                             label: Text('Reject'),
//                           ),
//                         ],
//                       ),
//                   ],
//                 ),
//               ),
//             ),
//             SizedBox(height: 24),
//             Expanded(
//               child: Obx(() {
//                 final transactions = _web3Service.transactionHistory;
                
//                 if (transactions.isEmpty) {
//                   return Center(
//                     child: Text(
//                       'No recent transactions',
//                       style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.white70),
//                     ),
//                   );
//                 }
                
//                 return ListView.builder(
//                   itemCount: transactions.length,
//                   itemBuilder: (context, index) {
//                     final tx = transactions[index];
//                     return GlassCard(
//                       margin: EdgeInsets.symmetric(vertical: 4),
//                       child: ListTile(
//                         leading: Icon(
//                           tx.status == TransactionStatus.confirmed
//                               ? Icons.check_circle_outline
//                               : tx.status == TransactionStatus.failed
//                                   ? Icons.error_outline
//                                   : Icons.hourglass_empty,
//                           color: tx.status == TransactionStatus.confirmed
//                               ? Colors.green
//                               : tx.status == TransactionStatus.failed
//                                   ? Colors.red
//                                   : null,
//                         ),
//                         title: Text(
//                           '${tx.value.toStringAsFixed(4)} ETH',
//                           style: TextStyle(color: Colors.white),
//                         ),
//                         subtitle: Text(
//                           tx.hash.substring(0, 10) + '...' + tx.hash.substring(tx.hash.length - 6),
//                           style: TextStyle(color: Colors.white70),
//                         ),
//                         trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white70),
//                         onTap: () {
//                           // Show transaction details
//                         },
//                       ),
//                     );
//                   },
//                 );
//               }),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _stopTransactionPolling();
//     _eventStreamController.close();
    
//     // Remove event listeners
//     connector.off('connect', _handleConnect);
//     connector.off('session_update', _handleSessionUpdate);
//     connector.off('disconnect', _handleDisconnect);
//     connector.off('call_request', _handleCallRequest);
//     connector.off('wc_sessionRequest', _handleRequest);
    
//     super.dispose();
//   }
// }

// enum WalletConnectEventType {
//   connect,
//   disconnect,
//   sessionUpdate,
//   request,
//   callRequest,
// }

// class WalletConnectEvent {
//   final WalletConnectEventType type;
//   final SessionStatus? session;
//   final dynamic request;
//   final CallRequest? callRequest;
//   final String? errorMessage;

//   WalletConnectEvent({
//     required this.type,
//     this.session,
//     this.request,
//     this.callRequest,
//     this.errorMessage,
//   });
// }

// class TransactionInfo {
//   final String hash;
//   final String from;
//   final String to;
//   final double value;
//   final TransactionStatus status;
//   final DateTime timestamp;
//   final String network;
//   final int? blockNumber;

//   TransactionInfo({
//     required this.hash,
//     required this.from,
//     required this.to,
//     required this.value,
//     required this.status,
//     required this.timestamp,
//     required this.network,
//     this.blockNumber,
//   });
// }

// enum TransactionStatus {
//   pending,
//   confirmed,
//   failed,
// }