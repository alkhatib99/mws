// utils/transaction_utils.dart

import 'package:web3dart/web3dart.dart';

extension TransactionUtils on Transaction {
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};
    
    if (to != null) {
      json['to'] = to!.hex;
    }
    
    if (from != null) {
      json['from'] = from!.hex;
    }
    
    if (value != null) {
      json['value'] = '0x${value!.getInWei.toInt().toRadixString(16)}';
    }
    
    if (maxGas != null) {
      json['gas'] = '0x${maxGas!.toInt().toRadixString(16)}';
    }
    
    if (gasPrice != null) {
      json['gasPrice'] = '0x${gasPrice!.getInWei.toInt().toRadixString(16)}';
    }
    
    if (data != null) {
      json['data'] = data;
    }
    
    return json;
  }
}