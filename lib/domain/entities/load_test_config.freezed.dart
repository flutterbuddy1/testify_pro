// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'load_test_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

LoadTestConfig _$LoadTestConfigFromJson(Map<String, dynamic> json) {
  return _LoadTestConfig.fromJson(json);
}

/// @nodoc
mixin _$LoadTestConfig {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;

  /// Test target - either a single request ID or flow ID
  String get targetId => throw _privateConstructorUsedError;
  TargetType get targetType => throw _privateConstructorUsedError;

  /// Number of virtual users to simulate
  int get virtualUsers => throw _privateConstructorUsedError;

  /// Test duration in seconds
  int get durationSeconds => throw _privateConstructorUsedError;

  /// Ramp-up time in seconds (gradual increase of users)
  int get rampUpSeconds => throw _privateConstructorUsedError;

  /// Ramp-down time in seconds (gradual decrease of users)
  int get rampDownSeconds => throw _privateConstructorUsedError;

  /// Target requests per second (0 = unlimited)
  int get targetRps => throw _privateConstructorUsedError;

  /// Think time between iterations in milliseconds
  int get thinkTimeMs => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this LoadTestConfig to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LoadTestConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LoadTestConfigCopyWith<LoadTestConfig> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LoadTestConfigCopyWith<$Res> {
  factory $LoadTestConfigCopyWith(
          LoadTestConfig value, $Res Function(LoadTestConfig) then) =
      _$LoadTestConfigCopyWithImpl<$Res, LoadTestConfig>;
  @useResult
  $Res call(
      {String id,
      String name,
      String targetId,
      TargetType targetType,
      int virtualUsers,
      int durationSeconds,
      int rampUpSeconds,
      int rampDownSeconds,
      int targetRps,
      int thinkTimeMs,
      DateTime createdAt});
}

/// @nodoc
class _$LoadTestConfigCopyWithImpl<$Res, $Val extends LoadTestConfig>
    implements $LoadTestConfigCopyWith<$Res> {
  _$LoadTestConfigCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LoadTestConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? targetId = null,
    Object? targetType = null,
    Object? virtualUsers = null,
    Object? durationSeconds = null,
    Object? rampUpSeconds = null,
    Object? rampDownSeconds = null,
    Object? targetRps = null,
    Object? thinkTimeMs = null,
    Object? createdAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      targetId: null == targetId
          ? _value.targetId
          : targetId // ignore: cast_nullable_to_non_nullable
              as String,
      targetType: null == targetType
          ? _value.targetType
          : targetType // ignore: cast_nullable_to_non_nullable
              as TargetType,
      virtualUsers: null == virtualUsers
          ? _value.virtualUsers
          : virtualUsers // ignore: cast_nullable_to_non_nullable
              as int,
      durationSeconds: null == durationSeconds
          ? _value.durationSeconds
          : durationSeconds // ignore: cast_nullable_to_non_nullable
              as int,
      rampUpSeconds: null == rampUpSeconds
          ? _value.rampUpSeconds
          : rampUpSeconds // ignore: cast_nullable_to_non_nullable
              as int,
      rampDownSeconds: null == rampDownSeconds
          ? _value.rampDownSeconds
          : rampDownSeconds // ignore: cast_nullable_to_non_nullable
              as int,
      targetRps: null == targetRps
          ? _value.targetRps
          : targetRps // ignore: cast_nullable_to_non_nullable
              as int,
      thinkTimeMs: null == thinkTimeMs
          ? _value.thinkTimeMs
          : thinkTimeMs // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LoadTestConfigImplCopyWith<$Res>
    implements $LoadTestConfigCopyWith<$Res> {
  factory _$$LoadTestConfigImplCopyWith(_$LoadTestConfigImpl value,
          $Res Function(_$LoadTestConfigImpl) then) =
      __$$LoadTestConfigImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String targetId,
      TargetType targetType,
      int virtualUsers,
      int durationSeconds,
      int rampUpSeconds,
      int rampDownSeconds,
      int targetRps,
      int thinkTimeMs,
      DateTime createdAt});
}

/// @nodoc
class __$$LoadTestConfigImplCopyWithImpl<$Res>
    extends _$LoadTestConfigCopyWithImpl<$Res, _$LoadTestConfigImpl>
    implements _$$LoadTestConfigImplCopyWith<$Res> {
  __$$LoadTestConfigImplCopyWithImpl(
      _$LoadTestConfigImpl _value, $Res Function(_$LoadTestConfigImpl) _then)
      : super(_value, _then);

  /// Create a copy of LoadTestConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? targetId = null,
    Object? targetType = null,
    Object? virtualUsers = null,
    Object? durationSeconds = null,
    Object? rampUpSeconds = null,
    Object? rampDownSeconds = null,
    Object? targetRps = null,
    Object? thinkTimeMs = null,
    Object? createdAt = null,
  }) {
    return _then(_$LoadTestConfigImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      targetId: null == targetId
          ? _value.targetId
          : targetId // ignore: cast_nullable_to_non_nullable
              as String,
      targetType: null == targetType
          ? _value.targetType
          : targetType // ignore: cast_nullable_to_non_nullable
              as TargetType,
      virtualUsers: null == virtualUsers
          ? _value.virtualUsers
          : virtualUsers // ignore: cast_nullable_to_non_nullable
              as int,
      durationSeconds: null == durationSeconds
          ? _value.durationSeconds
          : durationSeconds // ignore: cast_nullable_to_non_nullable
              as int,
      rampUpSeconds: null == rampUpSeconds
          ? _value.rampUpSeconds
          : rampUpSeconds // ignore: cast_nullable_to_non_nullable
              as int,
      rampDownSeconds: null == rampDownSeconds
          ? _value.rampDownSeconds
          : rampDownSeconds // ignore: cast_nullable_to_non_nullable
              as int,
      targetRps: null == targetRps
          ? _value.targetRps
          : targetRps // ignore: cast_nullable_to_non_nullable
              as int,
      thinkTimeMs: null == thinkTimeMs
          ? _value.thinkTimeMs
          : thinkTimeMs // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LoadTestConfigImpl implements _LoadTestConfig {
  const _$LoadTestConfigImpl(
      {required this.id,
      required this.name,
      required this.targetId,
      required this.targetType,
      required this.virtualUsers,
      required this.durationSeconds,
      this.rampUpSeconds = 0,
      this.rampDownSeconds = 0,
      this.targetRps = 0,
      this.thinkTimeMs = 1000,
      required this.createdAt});

  factory _$LoadTestConfigImpl.fromJson(Map<String, dynamic> json) =>
      _$$LoadTestConfigImplFromJson(json);

  @override
  final String id;
  @override
  final String name;

  /// Test target - either a single request ID or flow ID
  @override
  final String targetId;
  @override
  final TargetType targetType;

  /// Number of virtual users to simulate
  @override
  final int virtualUsers;

  /// Test duration in seconds
  @override
  final int durationSeconds;

  /// Ramp-up time in seconds (gradual increase of users)
  @override
  @JsonKey()
  final int rampUpSeconds;

  /// Ramp-down time in seconds (gradual decrease of users)
  @override
  @JsonKey()
  final int rampDownSeconds;

  /// Target requests per second (0 = unlimited)
  @override
  @JsonKey()
  final int targetRps;

  /// Think time between iterations in milliseconds
  @override
  @JsonKey()
  final int thinkTimeMs;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'LoadTestConfig(id: $id, name: $name, targetId: $targetId, targetType: $targetType, virtualUsers: $virtualUsers, durationSeconds: $durationSeconds, rampUpSeconds: $rampUpSeconds, rampDownSeconds: $rampDownSeconds, targetRps: $targetRps, thinkTimeMs: $thinkTimeMs, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LoadTestConfigImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.targetId, targetId) ||
                other.targetId == targetId) &&
            (identical(other.targetType, targetType) ||
                other.targetType == targetType) &&
            (identical(other.virtualUsers, virtualUsers) ||
                other.virtualUsers == virtualUsers) &&
            (identical(other.durationSeconds, durationSeconds) ||
                other.durationSeconds == durationSeconds) &&
            (identical(other.rampUpSeconds, rampUpSeconds) ||
                other.rampUpSeconds == rampUpSeconds) &&
            (identical(other.rampDownSeconds, rampDownSeconds) ||
                other.rampDownSeconds == rampDownSeconds) &&
            (identical(other.targetRps, targetRps) ||
                other.targetRps == targetRps) &&
            (identical(other.thinkTimeMs, thinkTimeMs) ||
                other.thinkTimeMs == thinkTimeMs) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      targetId,
      targetType,
      virtualUsers,
      durationSeconds,
      rampUpSeconds,
      rampDownSeconds,
      targetRps,
      thinkTimeMs,
      createdAt);

  /// Create a copy of LoadTestConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LoadTestConfigImplCopyWith<_$LoadTestConfigImpl> get copyWith =>
      __$$LoadTestConfigImplCopyWithImpl<_$LoadTestConfigImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LoadTestConfigImplToJson(
      this,
    );
  }
}

abstract class _LoadTestConfig implements LoadTestConfig {
  const factory _LoadTestConfig(
      {required final String id,
      required final String name,
      required final String targetId,
      required final TargetType targetType,
      required final int virtualUsers,
      required final int durationSeconds,
      final int rampUpSeconds,
      final int rampDownSeconds,
      final int targetRps,
      final int thinkTimeMs,
      required final DateTime createdAt}) = _$LoadTestConfigImpl;

  factory _LoadTestConfig.fromJson(Map<String, dynamic> json) =
      _$LoadTestConfigImpl.fromJson;

  @override
  String get id;
  @override
  String get name;

  /// Test target - either a single request ID or flow ID
  @override
  String get targetId;
  @override
  TargetType get targetType;

  /// Number of virtual users to simulate
  @override
  int get virtualUsers;

  /// Test duration in seconds
  @override
  int get durationSeconds;

  /// Ramp-up time in seconds (gradual increase of users)
  @override
  int get rampUpSeconds;

  /// Ramp-down time in seconds (gradual decrease of users)
  @override
  int get rampDownSeconds;

  /// Target requests per second (0 = unlimited)
  @override
  int get targetRps;

  /// Think time between iterations in milliseconds
  @override
  int get thinkTimeMs;
  @override
  DateTime get createdAt;

  /// Create a copy of LoadTestConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LoadTestConfigImplCopyWith<_$LoadTestConfigImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
