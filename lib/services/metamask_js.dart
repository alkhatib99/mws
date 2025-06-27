@JS()
library metamask;

import 'package:js/js.dart';

@JS('window.ethereum.request')
external dynamic _request(RequestArguments args);

@JS()
@anonymous
class RequestArguments {
  external String get method;
  external factory RequestArguments({String method});
}
