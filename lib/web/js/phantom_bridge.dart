@JS()
library phantom_bridge;

import 'package:js/js.dart';

@JS('window.solana')
external Phantom? get phantom;

@JS()
@anonymous
class Phantom {
  external bool get isPhantom;

  external Promise connect();
  external Account? get publicKey;
  external void on(String event, Function callback);
}

@JS()
@anonymous
class Account {
  external String toString();
}

@JS()
@anonymous
class Promise {
  external Promise then(Function success, [Function? error]);
}
