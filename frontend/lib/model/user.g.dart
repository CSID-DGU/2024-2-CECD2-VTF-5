// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$userImpl _$$userImplFromJson(Map<String, dynamic> json) => _$userImpl(
      login_id: json['login_id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      password: json['password'] as String,
      birth: json['birth'] as String,
      is_male: json['is_male'] as bool,
      has_child: json['has_child'] as bool,
      is_married: json['is_married'] as bool,
    );

Map<String, dynamic> _$$userImplToJson(_$userImpl instance) =>
    <String, dynamic>{
      'login_id': instance.login_id,
      'name': instance.name,
      'email': instance.email,
      'password': instance.password,
      'birth': instance.birth,
      'is_male': instance.is_male,
      'has_child': instance.has_child,
      'is_married': instance.is_married,
    };
