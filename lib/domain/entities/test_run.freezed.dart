// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'test_run.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

TestRun _$TestRunFromJson(Map<String, dynamic> json) {
  return _TestRun.fromJson(json);
}

/// @nodoc
mixin _$TestRun {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  TestType get type => throw _privateConstructorUsedError;
  TestStatus get status => throw _privateConstructorUsedError;
  DateTime get startTime => throw _privateConstructorUsedError;
  DateTime? get endTime => throw _privateConstructorUsedError;

  /// Configuration (varies by test type)
  Map<String, dynamic> get config => throw _privateConstructorUsedError;

  /// Final metrics snapshot
  TestMetrics? get finalMetrics => throw _privateConstructorUsedError;

  /// Additional metadata (e.g., flow result, request details)
  Map<String, dynamic> get metadata => throw _privateConstructorUsedError;

  /// Error messages if test failed
  String? get error => throw _privateConstructorUsedError;

  /// Serializes this TestRun to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TestRun
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TestRunCopyWith<TestRun> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TestRunCopyWith<$Res> {
  factory $TestRunCopyWith(TestRun value, $Res Function(TestRun) then) =
      _$TestRunCopyWithImpl<$Res, TestRun>;
  @useResult
  $Res call(
      {String id,
      String name,
      TestType type,
      TestStatus status,
      DateTime startTime,
      DateTime? endTime,
      Map<String, dynamic> config,
      TestMetrics? finalMetrics,
      Map<String, dynamic> metadata,
      String? error});

  $TestMetricsCopyWith<$Res>? get finalMetrics;
}

/// @nodoc
class _$TestRunCopyWithImpl<$Res, $Val extends TestRun>
    implements $TestRunCopyWith<$Res> {
  _$TestRunCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TestRun
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? type = null,
    Object? status = null,
    Object? startTime = null,
    Object? endTime = freezed,
    Object? config = null,
    Object? finalMetrics = freezed,
    Object? metadata = null,
    Object? error = freezed,
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
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as TestType,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as TestStatus,
      startTime: null == startTime
          ? _value.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endTime: freezed == endTime
          ? _value.endTime
          : endTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      config: null == config
          ? _value.config
          : config // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      finalMetrics: freezed == finalMetrics
          ? _value.finalMetrics
          : finalMetrics // ignore: cast_nullable_to_non_nullable
              as TestMetrics?,
      metadata: null == metadata
          ? _value.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }

  /// Create a copy of TestRun
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TestMetricsCopyWith<$Res>? get finalMetrics {
    if (_value.finalMetrics == null) {
      return null;
    }

    return $TestMetricsCopyWith<$Res>(_value.finalMetrics!, (value) {
      return _then(_value.copyWith(finalMetrics: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$TestRunImplCopyWith<$Res> implements $TestRunCopyWith<$Res> {
  factory _$$TestRunImplCopyWith(
          _$TestRunImpl value, $Res Function(_$TestRunImpl) then) =
      __$$TestRunImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      TestType type,
      TestStatus status,
      DateTime startTime,
      DateTime? endTime,
      Map<String, dynamic> config,
      TestMetrics? finalMetrics,
      Map<String, dynamic> metadata,
      String? error});

  @override
  $TestMetricsCopyWith<$Res>? get finalMetrics;
}

/// @nodoc
class __$$TestRunImplCopyWithImpl<$Res>
    extends _$TestRunCopyWithImpl<$Res, _$TestRunImpl>
    implements _$$TestRunImplCopyWith<$Res> {
  __$$TestRunImplCopyWithImpl(
      _$TestRunImpl _value, $Res Function(_$TestRunImpl) _then)
      : super(_value, _then);

  /// Create a copy of TestRun
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? type = null,
    Object? status = null,
    Object? startTime = null,
    Object? endTime = freezed,
    Object? config = null,
    Object? finalMetrics = freezed,
    Object? metadata = null,
    Object? error = freezed,
  }) {
    return _then(_$TestRunImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as TestType,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as TestStatus,
      startTime: null == startTime
          ? _value.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endTime: freezed == endTime
          ? _value.endTime
          : endTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      config: null == config
          ? _value._config
          : config // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      finalMetrics: freezed == finalMetrics
          ? _value.finalMetrics
          : finalMetrics // ignore: cast_nullable_to_non_nullable
              as TestMetrics?,
      metadata: null == metadata
          ? _value._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TestRunImpl implements _TestRun {
  const _$TestRunImpl(
      {required this.id,
      required this.name,
      required this.type,
      required this.status,
      required this.startTime,
      this.endTime,
      final Map<String, dynamic> config = const {},
      this.finalMetrics,
      final Map<String, dynamic> metadata = const {},
      this.error})
      : _config = config,
        _metadata = metadata;

  factory _$TestRunImpl.fromJson(Map<String, dynamic> json) =>
      _$$TestRunImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final TestType type;
  @override
  final TestStatus status;
  @override
  final DateTime startTime;
  @override
  final DateTime? endTime;

  /// Configuration (varies by test type)
  final Map<String, dynamic> _config;

  /// Configuration (varies by test type)
  @override
  @JsonKey()
  Map<String, dynamic> get config {
    if (_config is EqualUnmodifiableMapView) return _config;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_config);
  }

  /// Final metrics snapshot
  @override
  final TestMetrics? finalMetrics;

  /// Additional metadata (e.g., flow result, request details)
  final Map<String, dynamic> _metadata;

  /// Additional metadata (e.g., flow result, request details)
  @override
  @JsonKey()
  Map<String, dynamic> get metadata {
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_metadata);
  }

  /// Error messages if test failed
  @override
  final String? error;

  @override
  String toString() {
    return 'TestRun(id: $id, name: $name, type: $type, status: $status, startTime: $startTime, endTime: $endTime, config: $config, finalMetrics: $finalMetrics, metadata: $metadata, error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TestRunImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime) &&
            (identical(other.endTime, endTime) || other.endTime == endTime) &&
            const DeepCollectionEquality().equals(other._config, _config) &&
            (identical(other.finalMetrics, finalMetrics) ||
                other.finalMetrics == finalMetrics) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata) &&
            (identical(other.error, error) || other.error == error));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      type,
      status,
      startTime,
      endTime,
      const DeepCollectionEquality().hash(_config),
      finalMetrics,
      const DeepCollectionEquality().hash(_metadata),
      error);

  /// Create a copy of TestRun
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TestRunImplCopyWith<_$TestRunImpl> get copyWith =>
      __$$TestRunImplCopyWithImpl<_$TestRunImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TestRunImplToJson(
      this,
    );
  }
}

abstract class _TestRun implements TestRun {
  const factory _TestRun(
      {required final String id,
      required final String name,
      required final TestType type,
      required final TestStatus status,
      required final DateTime startTime,
      final DateTime? endTime,
      final Map<String, dynamic> config,
      final TestMetrics? finalMetrics,
      final Map<String, dynamic> metadata,
      final String? error}) = _$TestRunImpl;

  factory _TestRun.fromJson(Map<String, dynamic> json) = _$TestRunImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  TestType get type;
  @override
  TestStatus get status;
  @override
  DateTime get startTime;
  @override
  DateTime? get endTime;

  /// Configuration (varies by test type)
  @override
  Map<String, dynamic> get config;

  /// Final metrics snapshot
  @override
  TestMetrics? get finalMetrics;

  /// Additional metadata (e.g., flow result, request details)
  @override
  Map<String, dynamic> get metadata;

  /// Error messages if test failed
  @override
  String? get error;

  /// Create a copy of TestRun
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TestRunImplCopyWith<_$TestRunImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
