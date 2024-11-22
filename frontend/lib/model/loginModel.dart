import 'package:freezed_annotation/freezed_annotation.dart';

part 'loginModel.freezed.dart';

part 'loginModel.g.dart';

@freezed
class loginModel with _$loginModel {
  const factory loginModel({
    required String accessToken,
  }) = _loginModel;

  factory loginModel.fromJson(Map<String, dynamic> json) =>
      _$loginModelFromJson(json);
}
