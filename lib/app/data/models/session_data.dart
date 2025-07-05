import 'package:json_annotation/json_annotation.dart';

part 'session_data.g.dart';

@JsonSerializable()
class SessionData {
  final String walletName;
  final String address;
  final DateTime expiry;

  SessionData({
    required this.walletName,
    required this.address,
    required this.expiry,
  });

  factory SessionData.fromJson(Map<String, dynamic> json) =>
      _$SessionDataFromJson(json);

  Map<String, dynamic> toJson() => _$SessionDataToJson(this);
}


