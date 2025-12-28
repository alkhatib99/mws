// models/transaction_info.dart

enum TransactionStatus {
  pending,
  confirmed,
  failed,
}

class TransactionInfo {
  final String hash;
  final String from;
  final String to;
  final double value;
  final TransactionStatus status;
  final DateTime timestamp;
  final String network;
  final int? blockNumber;

  TransactionInfo({
    required this.hash,
    required this.from,
    required this.to,
    required this.value,
    required this.status,
    required this.timestamp,
    required this.network,
    this.blockNumber,
  });

  TransactionInfo copyWith({
    String? hash,
    String? from,
    String? to,
    double? value,
    TransactionStatus? status,
    DateTime? timestamp,
    String? network,
    int? blockNumber,
  }) {
    return TransactionInfo(
      hash: hash ?? this.hash,
      from: from ?? this.from,
      to: to ?? this.to,
      value: value ?? this.value,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
      network: network ?? this.network,
      blockNumber: blockNumber ?? this.blockNumber,
    );
  }
}

class TransactionDetails {
  final String hash;
  final String from;
  final String to;
  final double value;
  final double gasPrice;
  final int gasUsed;
  final DateTime timestamp;
  final TransactionStatus status;

  TransactionDetails({
    required this.hash,
    required this.from,
    required this.to,
    required this.value,
    required this.gasPrice,
    required this.gasUsed,
    required this.timestamp,
    required this.status,
  });
}