// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'test_metrics.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

TestMetrics _$TestMetricsFromJson(Map<String, dynamic> json) {
  return _TestMetrics.fromJson(json);
}

/// @nodoc
mixin _$TestMetrics {
  DateTime get timestamp => throw _privateConstructorUsedError;

  /// Total number of requests completed
  int get totalRequests => throw _privateConstructorUsedError;

  /// Successful requests (2xx status)
  int get successCount => throw _privateConstructorUsedError;

  /// Failed requests (4xx, 5xx, or errors)
  int get failureCount => throw _privateConstructorUsedError;

  /// Current requests per second
  double get currentRps => throw _privateConstructorUsedError;

  /// Average response time in milliseconds
  double get avgResponseTimeMs => throw _privateConstructorUsedError;

  /// Minimum response time
  double get minResponseTimeMs => throw _privateConstructorUsedError;

  /// Maximum response time
  double get maxResponseTimeMs => throw _privateConstructorUsedError;

  /// 50th percentile (median)
  double get p50ResponseTimeMs => throw _privateConstructorUsedError;

  /// 95th percentile
  double get p95ResponseTimeMs => throw _privateConstructorUsedError;

  /// 99th percentile
  double get p99ResponseTimeMs => throw _privateConstructorUsedError;

  /// Error rate (0.0 to 1.0)
  double get errorRate => throw _privateConstructorUsedError;

  /// Active virtual users
  int get activeUsers => throw _privateConstructorUsedError;

  /// Time series data for charting (last N seconds)
  List<DataPoint> get rpsHistory => throw _privateConstructorUsedError;
  List<DataPoint> get responseTimeHistory => throw _privateConstructorUsedError;
  List<DataPoint> get errorRateHistory => throw _privateConstructorUsedError;

  /// Serializes this TestMetrics to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TestMetrics
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TestMetricsCopyWith<TestMetrics> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TestMetricsCopyWith<$Res> {
  factory $TestMetricsCopyWith(
          TestMetrics value, $Res Function(TestMetrics) then) =
      _$TestMetricsCopyWithImpl<$Res, TestMetrics>;
  @useResult
  $Res call(
      {DateTime timestamp,
      int totalRequests,
      int successCount,
      int failureCount,
      double currentRps,
      double avgResponseTimeMs,
      double minResponseTimeMs,
      double maxResponseTimeMs,
      double p50ResponseTimeMs,
      double p95ResponseTimeMs,
      double p99ResponseTimeMs,
      double errorRate,
      int activeUsers,
      List<DataPoint> rpsHistory,
      List<DataPoint> responseTimeHistory,
      List<DataPoint> errorRateHistory});
}

/// @nodoc
class _$TestMetricsCopyWithImpl<$Res, $Val extends TestMetrics>
    implements $TestMetricsCopyWith<$Res> {
  _$TestMetricsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TestMetrics
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? timestamp = null,
    Object? totalRequests = null,
    Object? successCount = null,
    Object? failureCount = null,
    Object? currentRps = null,
    Object? avgResponseTimeMs = null,
    Object? minResponseTimeMs = null,
    Object? maxResponseTimeMs = null,
    Object? p50ResponseTimeMs = null,
    Object? p95ResponseTimeMs = null,
    Object? p99ResponseTimeMs = null,
    Object? errorRate = null,
    Object? activeUsers = null,
    Object? rpsHistory = null,
    Object? responseTimeHistory = null,
    Object? errorRateHistory = null,
  }) {
    return _then(_value.copyWith(
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      totalRequests: null == totalRequests
          ? _value.totalRequests
          : totalRequests // ignore: cast_nullable_to_non_nullable
              as int,
      successCount: null == successCount
          ? _value.successCount
          : successCount // ignore: cast_nullable_to_non_nullable
              as int,
      failureCount: null == failureCount
          ? _value.failureCount
          : failureCount // ignore: cast_nullable_to_non_nullable
              as int,
      currentRps: null == currentRps
          ? _value.currentRps
          : currentRps // ignore: cast_nullable_to_non_nullable
              as double,
      avgResponseTimeMs: null == avgResponseTimeMs
          ? _value.avgResponseTimeMs
          : avgResponseTimeMs // ignore: cast_nullable_to_non_nullable
              as double,
      minResponseTimeMs: null == minResponseTimeMs
          ? _value.minResponseTimeMs
          : minResponseTimeMs // ignore: cast_nullable_to_non_nullable
              as double,
      maxResponseTimeMs: null == maxResponseTimeMs
          ? _value.maxResponseTimeMs
          : maxResponseTimeMs // ignore: cast_nullable_to_non_nullable
              as double,
      p50ResponseTimeMs: null == p50ResponseTimeMs
          ? _value.p50ResponseTimeMs
          : p50ResponseTimeMs // ignore: cast_nullable_to_non_nullable
              as double,
      p95ResponseTimeMs: null == p95ResponseTimeMs
          ? _value.p95ResponseTimeMs
          : p95ResponseTimeMs // ignore: cast_nullable_to_non_nullable
              as double,
      p99ResponseTimeMs: null == p99ResponseTimeMs
          ? _value.p99ResponseTimeMs
          : p99ResponseTimeMs // ignore: cast_nullable_to_non_nullable
              as double,
      errorRate: null == errorRate
          ? _value.errorRate
          : errorRate // ignore: cast_nullable_to_non_nullable
              as double,
      activeUsers: null == activeUsers
          ? _value.activeUsers
          : activeUsers // ignore: cast_nullable_to_non_nullable
              as int,
      rpsHistory: null == rpsHistory
          ? _value.rpsHistory
          : rpsHistory // ignore: cast_nullable_to_non_nullable
              as List<DataPoint>,
      responseTimeHistory: null == responseTimeHistory
          ? _value.responseTimeHistory
          : responseTimeHistory // ignore: cast_nullable_to_non_nullable
              as List<DataPoint>,
      errorRateHistory: null == errorRateHistory
          ? _value.errorRateHistory
          : errorRateHistory // ignore: cast_nullable_to_non_nullable
              as List<DataPoint>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TestMetricsImplCopyWith<$Res>
    implements $TestMetricsCopyWith<$Res> {
  factory _$$TestMetricsImplCopyWith(
          _$TestMetricsImpl value, $Res Function(_$TestMetricsImpl) then) =
      __$$TestMetricsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {DateTime timestamp,
      int totalRequests,
      int successCount,
      int failureCount,
      double currentRps,
      double avgResponseTimeMs,
      double minResponseTimeMs,
      double maxResponseTimeMs,
      double p50ResponseTimeMs,
      double p95ResponseTimeMs,
      double p99ResponseTimeMs,
      double errorRate,
      int activeUsers,
      List<DataPoint> rpsHistory,
      List<DataPoint> responseTimeHistory,
      List<DataPoint> errorRateHistory});
}

/// @nodoc
class __$$TestMetricsImplCopyWithImpl<$Res>
    extends _$TestMetricsCopyWithImpl<$Res, _$TestMetricsImpl>
    implements _$$TestMetricsImplCopyWith<$Res> {
  __$$TestMetricsImplCopyWithImpl(
      _$TestMetricsImpl _value, $Res Function(_$TestMetricsImpl) _then)
      : super(_value, _then);

  /// Create a copy of TestMetrics
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? timestamp = null,
    Object? totalRequests = null,
    Object? successCount = null,
    Object? failureCount = null,
    Object? currentRps = null,
    Object? avgResponseTimeMs = null,
    Object? minResponseTimeMs = null,
    Object? maxResponseTimeMs = null,
    Object? p50ResponseTimeMs = null,
    Object? p95ResponseTimeMs = null,
    Object? p99ResponseTimeMs = null,
    Object? errorRate = null,
    Object? activeUsers = null,
    Object? rpsHistory = null,
    Object? responseTimeHistory = null,
    Object? errorRateHistory = null,
  }) {
    return _then(_$TestMetricsImpl(
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      totalRequests: null == totalRequests
          ? _value.totalRequests
          : totalRequests // ignore: cast_nullable_to_non_nullable
              as int,
      successCount: null == successCount
          ? _value.successCount
          : successCount // ignore: cast_nullable_to_non_nullable
              as int,
      failureCount: null == failureCount
          ? _value.failureCount
          : failureCount // ignore: cast_nullable_to_non_nullable
              as int,
      currentRps: null == currentRps
          ? _value.currentRps
          : currentRps // ignore: cast_nullable_to_non_nullable
              as double,
      avgResponseTimeMs: null == avgResponseTimeMs
          ? _value.avgResponseTimeMs
          : avgResponseTimeMs // ignore: cast_nullable_to_non_nullable
              as double,
      minResponseTimeMs: null == minResponseTimeMs
          ? _value.minResponseTimeMs
          : minResponseTimeMs // ignore: cast_nullable_to_non_nullable
              as double,
      maxResponseTimeMs: null == maxResponseTimeMs
          ? _value.maxResponseTimeMs
          : maxResponseTimeMs // ignore: cast_nullable_to_non_nullable
              as double,
      p50ResponseTimeMs: null == p50ResponseTimeMs
          ? _value.p50ResponseTimeMs
          : p50ResponseTimeMs // ignore: cast_nullable_to_non_nullable
              as double,
      p95ResponseTimeMs: null == p95ResponseTimeMs
          ? _value.p95ResponseTimeMs
          : p95ResponseTimeMs // ignore: cast_nullable_to_non_nullable
              as double,
      p99ResponseTimeMs: null == p99ResponseTimeMs
          ? _value.p99ResponseTimeMs
          : p99ResponseTimeMs // ignore: cast_nullable_to_non_nullable
              as double,
      errorRate: null == errorRate
          ? _value.errorRate
          : errorRate // ignore: cast_nullable_to_non_nullable
              as double,
      activeUsers: null == activeUsers
          ? _value.activeUsers
          : activeUsers // ignore: cast_nullable_to_non_nullable
              as int,
      rpsHistory: null == rpsHistory
          ? _value._rpsHistory
          : rpsHistory // ignore: cast_nullable_to_non_nullable
              as List<DataPoint>,
      responseTimeHistory: null == responseTimeHistory
          ? _value._responseTimeHistory
          : responseTimeHistory // ignore: cast_nullable_to_non_nullable
              as List<DataPoint>,
      errorRateHistory: null == errorRateHistory
          ? _value._errorRateHistory
          : errorRateHistory // ignore: cast_nullable_to_non_nullable
              as List<DataPoint>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TestMetricsImpl implements _TestMetrics {
  const _$TestMetricsImpl(
      {required this.timestamp,
      this.totalRequests = 0,
      this.successCount = 0,
      this.failureCount = 0,
      this.currentRps = 0.0,
      this.avgResponseTimeMs = 0.0,
      this.minResponseTimeMs = 0.0,
      this.maxResponseTimeMs = 0.0,
      this.p50ResponseTimeMs = 0.0,
      this.p95ResponseTimeMs = 0.0,
      this.p99ResponseTimeMs = 0.0,
      this.errorRate = 0.0,
      this.activeUsers = 0,
      final List<DataPoint> rpsHistory = const [],
      final List<DataPoint> responseTimeHistory = const [],
      final List<DataPoint> errorRateHistory = const []})
      : _rpsHistory = rpsHistory,
        _responseTimeHistory = responseTimeHistory,
        _errorRateHistory = errorRateHistory;

  factory _$TestMetricsImpl.fromJson(Map<String, dynamic> json) =>
      _$$TestMetricsImplFromJson(json);

  @override
  final DateTime timestamp;

  /// Total number of requests completed
  @override
  @JsonKey()
  final int totalRequests;

  /// Successful requests (2xx status)
  @override
  @JsonKey()
  final int successCount;

  /// Failed requests (4xx, 5xx, or errors)
  @override
  @JsonKey()
  final int failureCount;

  /// Current requests per second
  @override
  @JsonKey()
  final double currentRps;

  /// Average response time in milliseconds
  @override
  @JsonKey()
  final double avgResponseTimeMs;

  /// Minimum response time
  @override
  @JsonKey()
  final double minResponseTimeMs;

  /// Maximum response time
  @override
  @JsonKey()
  final double maxResponseTimeMs;

  /// 50th percentile (median)
  @override
  @JsonKey()
  final double p50ResponseTimeMs;

  /// 95th percentile
  @override
  @JsonKey()
  final double p95ResponseTimeMs;

  /// 99th percentile
  @override
  @JsonKey()
  final double p99ResponseTimeMs;

  /// Error rate (0.0 to 1.0)
  @override
  @JsonKey()
  final double errorRate;

  /// Active virtual users
  @override
  @JsonKey()
  final int activeUsers;

  /// Time series data for charting (last N seconds)
  final List<DataPoint> _rpsHistory;

  /// Time series data for charting (last N seconds)
  @override
  @JsonKey()
  List<DataPoint> get rpsHistory {
    if (_rpsHistory is EqualUnmodifiableListView) return _rpsHistory;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_rpsHistory);
  }

  final List<DataPoint> _responseTimeHistory;
  @override
  @JsonKey()
  List<DataPoint> get responseTimeHistory {
    if (_responseTimeHistory is EqualUnmodifiableListView)
      return _responseTimeHistory;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_responseTimeHistory);
  }

  final List<DataPoint> _errorRateHistory;
  @override
  @JsonKey()
  List<DataPoint> get errorRateHistory {
    if (_errorRateHistory is EqualUnmodifiableListView)
      return _errorRateHistory;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_errorRateHistory);
  }

  @override
  String toString() {
    return 'TestMetrics(timestamp: $timestamp, totalRequests: $totalRequests, successCount: $successCount, failureCount: $failureCount, currentRps: $currentRps, avgResponseTimeMs: $avgResponseTimeMs, minResponseTimeMs: $minResponseTimeMs, maxResponseTimeMs: $maxResponseTimeMs, p50ResponseTimeMs: $p50ResponseTimeMs, p95ResponseTimeMs: $p95ResponseTimeMs, p99ResponseTimeMs: $p99ResponseTimeMs, errorRate: $errorRate, activeUsers: $activeUsers, rpsHistory: $rpsHistory, responseTimeHistory: $responseTimeHistory, errorRateHistory: $errorRateHistory)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TestMetricsImpl &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.totalRequests, totalRequests) ||
                other.totalRequests == totalRequests) &&
            (identical(other.successCount, successCount) ||
                other.successCount == successCount) &&
            (identical(other.failureCount, failureCount) ||
                other.failureCount == failureCount) &&
            (identical(other.currentRps, currentRps) ||
                other.currentRps == currentRps) &&
            (identical(other.avgResponseTimeMs, avgResponseTimeMs) ||
                other.avgResponseTimeMs == avgResponseTimeMs) &&
            (identical(other.minResponseTimeMs, minResponseTimeMs) ||
                other.minResponseTimeMs == minResponseTimeMs) &&
            (identical(other.maxResponseTimeMs, maxResponseTimeMs) ||
                other.maxResponseTimeMs == maxResponseTimeMs) &&
            (identical(other.p50ResponseTimeMs, p50ResponseTimeMs) ||
                other.p50ResponseTimeMs == p50ResponseTimeMs) &&
            (identical(other.p95ResponseTimeMs, p95ResponseTimeMs) ||
                other.p95ResponseTimeMs == p95ResponseTimeMs) &&
            (identical(other.p99ResponseTimeMs, p99ResponseTimeMs) ||
                other.p99ResponseTimeMs == p99ResponseTimeMs) &&
            (identical(other.errorRate, errorRate) ||
                other.errorRate == errorRate) &&
            (identical(other.activeUsers, activeUsers) ||
                other.activeUsers == activeUsers) &&
            const DeepCollectionEquality()
                .equals(other._rpsHistory, _rpsHistory) &&
            const DeepCollectionEquality()
                .equals(other._responseTimeHistory, _responseTimeHistory) &&
            const DeepCollectionEquality()
                .equals(other._errorRateHistory, _errorRateHistory));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      timestamp,
      totalRequests,
      successCount,
      failureCount,
      currentRps,
      avgResponseTimeMs,
      minResponseTimeMs,
      maxResponseTimeMs,
      p50ResponseTimeMs,
      p95ResponseTimeMs,
      p99ResponseTimeMs,
      errorRate,
      activeUsers,
      const DeepCollectionEquality().hash(_rpsHistory),
      const DeepCollectionEquality().hash(_responseTimeHistory),
      const DeepCollectionEquality().hash(_errorRateHistory));

  /// Create a copy of TestMetrics
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TestMetricsImplCopyWith<_$TestMetricsImpl> get copyWith =>
      __$$TestMetricsImplCopyWithImpl<_$TestMetricsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TestMetricsImplToJson(
      this,
    );
  }
}

abstract class _TestMetrics implements TestMetrics {
  const factory _TestMetrics(
      {required final DateTime timestamp,
      final int totalRequests,
      final int successCount,
      final int failureCount,
      final double currentRps,
      final double avgResponseTimeMs,
      final double minResponseTimeMs,
      final double maxResponseTimeMs,
      final double p50ResponseTimeMs,
      final double p95ResponseTimeMs,
      final double p99ResponseTimeMs,
      final double errorRate,
      final int activeUsers,
      final List<DataPoint> rpsHistory,
      final List<DataPoint> responseTimeHistory,
      final List<DataPoint> errorRateHistory}) = _$TestMetricsImpl;

  factory _TestMetrics.fromJson(Map<String, dynamic> json) =
      _$TestMetricsImpl.fromJson;

  @override
  DateTime get timestamp;

  /// Total number of requests completed
  @override
  int get totalRequests;

  /// Successful requests (2xx status)
  @override
  int get successCount;

  /// Failed requests (4xx, 5xx, or errors)
  @override
  int get failureCount;

  /// Current requests per second
  @override
  double get currentRps;

  /// Average response time in milliseconds
  @override
  double get avgResponseTimeMs;

  /// Minimum response time
  @override
  double get minResponseTimeMs;

  /// Maximum response time
  @override
  double get maxResponseTimeMs;

  /// 50th percentile (median)
  @override
  double get p50ResponseTimeMs;

  /// 95th percentile
  @override
  double get p95ResponseTimeMs;

  /// 99th percentile
  @override
  double get p99ResponseTimeMs;

  /// Error rate (0.0 to 1.0)
  @override
  double get errorRate;

  /// Active virtual users
  @override
  int get activeUsers;

  /// Time series data for charting (last N seconds)
  @override
  List<DataPoint> get rpsHistory;
  @override
  List<DataPoint> get responseTimeHistory;
  @override
  List<DataPoint> get errorRateHistory;

  /// Create a copy of TestMetrics
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TestMetricsImplCopyWith<_$TestMetricsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DataPoint _$DataPointFromJson(Map<String, dynamic> json) {
  return _DataPoint.fromJson(json);
}

/// @nodoc
mixin _$DataPoint {
  DateTime get timestamp => throw _privateConstructorUsedError;
  double get value => throw _privateConstructorUsedError;

  /// Serializes this DataPoint to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DataPoint
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DataPointCopyWith<DataPoint> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DataPointCopyWith<$Res> {
  factory $DataPointCopyWith(DataPoint value, $Res Function(DataPoint) then) =
      _$DataPointCopyWithImpl<$Res, DataPoint>;
  @useResult
  $Res call({DateTime timestamp, double value});
}

/// @nodoc
class _$DataPointCopyWithImpl<$Res, $Val extends DataPoint>
    implements $DataPointCopyWith<$Res> {
  _$DataPointCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DataPoint
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? timestamp = null,
    Object? value = null,
  }) {
    return _then(_value.copyWith(
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      value: null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DataPointImplCopyWith<$Res>
    implements $DataPointCopyWith<$Res> {
  factory _$$DataPointImplCopyWith(
          _$DataPointImpl value, $Res Function(_$DataPointImpl) then) =
      __$$DataPointImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({DateTime timestamp, double value});
}

/// @nodoc
class __$$DataPointImplCopyWithImpl<$Res>
    extends _$DataPointCopyWithImpl<$Res, _$DataPointImpl>
    implements _$$DataPointImplCopyWith<$Res> {
  __$$DataPointImplCopyWithImpl(
      _$DataPointImpl _value, $Res Function(_$DataPointImpl) _then)
      : super(_value, _then);

  /// Create a copy of DataPoint
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? timestamp = null,
    Object? value = null,
  }) {
    return _then(_$DataPointImpl(
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      value: null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DataPointImpl implements _DataPoint {
  const _$DataPointImpl({required this.timestamp, required this.value});

  factory _$DataPointImpl.fromJson(Map<String, dynamic> json) =>
      _$$DataPointImplFromJson(json);

  @override
  final DateTime timestamp;
  @override
  final double value;

  @override
  String toString() {
    return 'DataPoint(timestamp: $timestamp, value: $value)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DataPointImpl &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.value, value) || other.value == value));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, timestamp, value);

  /// Create a copy of DataPoint
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DataPointImplCopyWith<_$DataPointImpl> get copyWith =>
      __$$DataPointImplCopyWithImpl<_$DataPointImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DataPointImplToJson(
      this,
    );
  }
}

abstract class _DataPoint implements DataPoint {
  const factory _DataPoint(
      {required final DateTime timestamp,
      required final double value}) = _$DataPointImpl;

  factory _DataPoint.fromJson(Map<String, dynamic> json) =
      _$DataPointImpl.fromJson;

  @override
  DateTime get timestamp;
  @override
  double get value;

  /// Create a copy of DataPoint
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DataPointImplCopyWith<_$DataPointImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
