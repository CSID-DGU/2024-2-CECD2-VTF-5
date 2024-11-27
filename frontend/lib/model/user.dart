import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
class user with _$user{
  factory user({
    required String login_id,
    required String name,
    required String email,
    required String password,
    required String birth,
    required bool is_male,
    required bool has_child,
    required bool is_married,
}) = _user;
  factory user.fromJson(Map<String,dynamic>json)=>_$userFromJson(json);
}