import 'dart:js_interop';
import 'package:flutter_web3/flutter_web3.dart';
import 'package:mws/services/metamask_js.dart';

class MetaMaskService {
  static Ethereum? get ethereum => JS('window.ethereum') as Ethereum?;

  static Future<String?> connect() async {
    if (ethereum == null) return null;

    try {
      final jsPromise = ethereum!.request(
              RequestArguments(method: 'eth_requestAccounts') as String)
          as JSPromise;
      final jsResult =
          await jsPromise.toDart; // Convert JS Promise to Dart Future
      final accounts = jsResult as JSArray;
      final address = accounts[0] as String;
      return address;
    } catch (e) {
      print('MetaMask connect error: $e');
      return null;
    }
  }

  static Future<String?> getCurrentAddress() async {
    if (ethereum == null) return null;

    try {
      final jsPromise =
          ethereum!.request(RequestArguments(method: 'eth_accounts') as String)
              as JSPromise;
      final jsResult = await jsPromise.toDart;
      final accounts = jsResult as JSArray;
      final address = accounts[0] as String;
      return address;
    } catch (e) {
      print('MetaMask account fetch error: $e');
      return null;
    }
  }

  static bool isAvailable() => ethereum != null;
}
