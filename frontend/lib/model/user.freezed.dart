// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

user _$userFromJson(Map<String, dynamic> json) {
  return _user.fromJson(json);
}

/// @nodoc
mixin _$user {
  String get login_id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  String get password => throw _privateConstructorUsedError;
  String get birth => throw _privateConstructorUsedError;
  bool get is_male => throw _privateConstructorUsedError;
  bool get has_child => throw _privateConstructorUsedError;
  bool get is_married => throw _privateConstructorUsedError;

  /// Serializes this user to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of user
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $userCopyWith<user> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $userCopyWith<$Res> {
  factory $userCopyWith(user value, $Res Function(user) then) =
      _$userCopyWithImpl<$Res, user>;
  @useResult
  $Res call(
      {String login_id,
      String name,
      String email,
      String password,
      String birth,
      bool is_male,
      bool has_child,
      bool is_married});
}

/// @nodoc
class _$userCopyWithImpl<$Res, $Val extends user>
    implements $userCopyWith<$Res> {
  _$userCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of user
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? login_id = null,
    Object? name = null,
    Object? email = null,
    Object? password = null,
    Object? birth = null,
    Object? is_male = null,
    Object? has_child = null,
    Object? is_married = null,
  }) {
    return _then(_value.copyWith(
      login_id: null == login_id
          ? _value.login_id
          : login_id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      password: null == password
          ? _value.password
          : password // ignore: cast_nullable_to_non_nullable
              as String,
      birth: null == birth
          ? _value.birth
          : birth // ignore: cast_nullable_to_non_nullable
              as String,
      is_male: null == is_male
          ? _value.is_male
          : is_male // ignore: cast_nullable_to_non_nullable
              as bool,
      has_child: null == has_child
          ? _value.has_child
          : has_child // ignore: cast_nullable_to_non_nullable
              as bool,
      is_married: null == is_married
          ? _value.is_married
          : is_married // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$userImplCopyWith<$Res> implements $userCopyWith<$Res> {
  factory _$$userImplCopyWith(
          _$userImpl value, $Res Function(_$userImpl) then) =
      __$$userImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String login_id,
      String name,
      String email,
      String password,
      String birth,
      bool is_male,
      bool has_child,
      bool is_married});
}

/// @nodoc
class __$$userImplCopyWithImpl<$Res>
    extends _$userCopyWithImpl<$Res, _$userImpl>
    implements _$$userImplCopyWith<$Res> {
  __$$userImplCopyWithImpl(_$userImpl _value, $Res Function(_$userImpl) _then)
      : super(_value, _then);

  /// Create a copy of user
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? login_id = null,
    Object? name = null,
    Object? email = null,
    Object? password = null,
    Object? birth = null,
    Object? is_male = null,
    Object? has_child = null,
    Object? is_married = null,
  }) {
    return _then(_$userImpl(
      login_id: null == login_id
          ? _value.login_id
          : login_id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      password: null == password
          ? _value.password
          : password // ignore: cast_nullable_to_non_nullable
              as String,
      birth: null == birth
          ? _value.birth
          : birth // ignore: cast_nullable_to_non_nullable
              as String,
      is_male: null == is_male
          ? _value.is_male
          : is_male // ignore: cast_nullable_to_non_nullable
              as bool,
      has_child: null == has_child
          ? _value.has_child
          : has_child // ignore: cast_nullable_to_non_nullable
              as bool,
      is_married: null == is_married
          ? _value.is_married
          : is_married // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$userImpl implements _user {
  _$userImpl(
      {required this.login_id,
      required this.name,
      required this.email,
      required this.password,
      required this.birth,
      required this.is_male,
      required this.has_child,
      required this.is_married});

  factory _$userImpl.fromJson(Map<String, dynamic> json) =>
      _$$userImplFromJson(json);

  @override
  final String login_id;
  @override
  final String name;
  @override
  final String email;
  @override
  final String password;
  @override
  final String birth;
  @override
  final bool is_male;
  @override
  final bool has_child;
  @override
  final bool is_married;

  @override
  String toString() {
    return 'user(login_id: $login_id, name: $name, email: $email, password: $password, birth: $birth, is_male: $is_male, has_child: $has_child, is_married: $is_married)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$userImpl &&
            (identical(other.login_id, login_id) ||
                other.login_id == login_id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.password, password) ||
                other.password == password) &&
            (identical(other.birth, birth) || other.birth == birth) &&
            (identical(other.is_male, is_male) || other.is_male == is_male) &&
            (identical(other.has_child, has_child) ||
                other.has_child == has_child) &&
            (identical(other.is_married, is_married) ||
                other.is_married == is_married));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, login_id, name, email, password,
      birth, is_male, has_child, is_married);

  /// Create a copy of user
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$userImplCopyWith<_$userImpl> get copyWith =>
      __$$userImplCopyWithImpl<_$userImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$userImplToJson(
      this,
    );
  }
}

abstract class _user implements user {
  factory _user(
      {required final String login_id,
      required final String name,
      required final String email,
      required final String password,
      required final String birth,
      required final bool is_male,
      required final bool has_child,
      required final bool is_married}) = _$userImpl;

  factory _user.fromJson(Map<String, dynamic> json) = _$userImpl.fromJson;

  @override
  String get login_id;
  @override
  String get name;
  @override
  String get email;
  @override
  String get password;
  @override
  String get birth;
  @override
  bool get is_male;
  @override
  bool get has_child;
  @override
  bool get is_married;

  /// Create a copy of user
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$userImplCopyWith<_$userImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
