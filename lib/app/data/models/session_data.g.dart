// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SessionData _$SessionDataFromJson(Map<String, dynamic> json) => SessionData(
      walletName: json['walletName'] as String,
      address: json['address'] as String,
      expiry: DateTime.parse(json['expiry'] as String),
    );

Map<String, dynamic> _$SessionDataToJson(SessionData instance) =>
    <String, dynamic>{
      'walletName': instance.walletName,
      'address': instance.address,
      'expiry': instance.expiry.toIso8601String(),
    };
