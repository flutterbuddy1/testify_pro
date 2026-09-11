// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'api_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ApiResponse _$ApiResponseFromJson(Map<String, dynamic> json) {
  return _ApiResponse.fromJson(json);
}

/// @nodoc
mixin _$ApiResponse {
  int get statusCode => throw _privateConstructorUsedError;
  String get statusMessage => throw _privateConstructorUsedError;
  Map<String, dynamic> get headers => throw _privateConstructorUsedError;
  String get body => throw _privateConstructorUsedError;
  int get responseTimeMs => throw _privateConstructorUsedError;
  int get sizeBytes => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ApiResponseCopyWith<ApiResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ApiResponseCopyWith<$Res> {
  factory $ApiResponseCopyWith(
          ApiResponse value, $Res Function(ApiResponse) then) =
      _$ApiResponseCopyWithImpl<$Res, ApiResponse>;
  @useResult
  $Res call(
      {int statusCode,
      String statusMessage,
      Map<String, dynamic> headers,
      String body,
      int responseTimeMs,
      int sizeBytes,
      DateTime timestamp,
      String? error});
}

/// @nodoc
class _$ApiResponseCopyWithImpl<$Res, $Val extends ApiResponse>
    implements $ApiResponseCopyWith<$Res> {
  _$ApiResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? statusCode = null,
    Object? statusMessage = null,
    Object? headers = null,
    Object? body = null,
    Object? responseTimeMs = null,
    Object? sizeBytes = null,
    Object? timestamp = null,
    Object? error = freezed,
  }) {
    return _then(_value.copyWith(
      statusCode: null == statusCode
          ? _value.statusCode
          : statusCode // ignore: cast_nullable_to_non_nullable
              as int,
      statusMessage: null == statusMessage
          ? _value.statusMessage
          : statusMessage // ignore: cast_nullable_to_non_nullable
              as String,
      headers: null == headers
          ? _value.headers
          : headers // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      body: null == body
          ? _value.body
          : body // ignore: cast_nullable_to_non_nullable
              as String,
      responseTimeMs: null == responseTimeMs
          ? _value.responseTimeMs
          : responseTimeMs // ignore: cast_nullable_to_non_nullable
              as int,
      sizeBytes: null == sizeBytes
          ? _value.sizeBytes
          : sizeBytes // ignore: cast_nullable_to_non_nullable
              as int,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ApiResponseImplCopyWith<$Res>
    implements $ApiResponseCopyWith<$Res> {
  factory _$$ApiResponseImplCopyWith(
          _$ApiResponseImpl value, $Res Function(_$ApiResponseImpl) then) =
      __$$ApiResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int statusCode,
      String statusMessage,
      Map<String, dynamic> headers,
      String body,
      int responseTimeMs,
      int sizeBytes,
      DateTime timestamp,
      String? error});
}

/// @nodoc
class __$$ApiResponseImplCopyWithImpl<$Res>
    extends _$ApiResponseCopyWithImpl<$Res, _$ApiResponseImpl>
    implements _$$ApiResponseImplCopyWith<$Res> {
  __$$ApiResponseImplCopyWithImpl(
      _$ApiResponseImpl _value, $Res Function(_$ApiResponseImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? statusCode = null,
    Object? statusMessage = null,
    Object? headers = null,
    Object? body = null,
    Object? responseTimeMs = null,
    Object? sizeBytes = null,
    Object? timestamp = null,
    Object? error = freezed,
  }) {
    return _then(_$ApiResponseImpl(
      statusCode: null == statusCode
          ? _value.statusCode
          : statusCode // ignore: cast_nullable_to_non_nullable
              as int,
      statusMessage: null == statusMessage
          ? _value.statusMessage
          : statusMessage // ignore: cast_nullable_to_non_nullable
              as String,
      headers: null == headers
          ? _value._headers
          : headers // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      body: null == body
          ? _value.body
          : body // ignore: cast_nullable_to_non_nullable
              as String,
      responseTimeMs: null == responseTimeMs
          ? _value.responseTimeMs
          : responseTimeMs // ignore: cast_nullable_to_non_nullable
              as int,
      sizeBytes: null == sizeBytes
          ? _value.sizeBytes
          : sizeBytes // ignore: cast_nullable_to_non_nullable
              as int,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ApiResponseImpl implements _ApiResponse {
  const _$ApiResponseImpl(
      {required this.statusCode,
      required this.statusMessage,
      required final Map<String, dynamic> headers,
      required this.body,
      required this.responseTimeMs,
      required this.sizeBytes,
      required this.timestamp,
      this.error})
      : _headers = headers;

  factory _$ApiResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$ApiResponseImplFromJson(json);

  @override
  final int statusCode;
  @override
  final String statusMessage;
  final Map<String, dynamic> _headers;
  @override
  Map<String, dynamic> get headers {
    if (_headers is EqualUnmodifiableMapView) return _headers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_headers);
  }

  @override
  final String body;
  @override
  final int responseTimeMs;
  @override
  final int sizeBytes;
  @override
  final DateTime timestamp;
  @override
  final String? error;

  @override
  String toString() {
    return 'ApiResponse(statusCode: $statusCode, statusMessage: $statusMessage, headers: $headers, body: $body, responseTimeMs: $responseTimeMs, sizeBytes: $sizeBytes, timestamp: $timestamp, error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ApiResponseImpl &&
            (identical(other.statusCode, statusCode) ||
                other.statusCode == statusCode) &&
            (identical(other.statusMessage, statusMessage) ||
                other.statusMessage == statusMessage) &&
            const DeepCollectionEquality().equals(other._headers, _headers) &&
            (identical(other.body, body) || other.body == body) &&
            (identical(other.responseTimeMs, responseTimeMs) ||
                other.responseTimeMs == responseTimeMs) &&
            (identical(other.sizeBytes, sizeBytes) ||
                other.sizeBytes == sizeBytes) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.error, error) || other.error == error));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      statusCode,
      statusMessage,
      const DeepCollectionEquality().hash(_headers),
      body,
      responseTimeMs,
      sizeBytes,
      timestamp,
      error);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ApiResponseImplCopyWith<_$ApiResponseImpl> get copyWith =>
      __$$ApiResponseImplCopyWithImpl<_$ApiResponseImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ApiResponseImplToJson(
      this,
    );
  }
}

abstract class _ApiResponse implements ApiResponse {
  const factory _ApiResponse(
      {required final int statusCode,
      required final String statusMessage,
      required final Map<String, dynamic> headers,
      required final String body,
      required final int responseTimeMs,
      required final int sizeBytes,
      required final DateTime timestamp,
      final String? error}) = _$ApiResponseImpl;

  factory _ApiResponse.fromJson(Map<String, dynamic> json) =
      _$ApiResponseImpl.fromJson;

  @override
  int get statusCode;
  @override
  String get statusMessage;
  @override
  Map<String, dynamic> get headers;
  @override
  String get body;
  @override
  int get responseTimeMs;
  @override
  int get sizeBytes;
  @override
  DateTime get timestamp;
  @override
  String? get error;
  @override
  @JsonKey(ignore: true)
  _$$ApiResponseImplCopyWith<_$ApiResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
