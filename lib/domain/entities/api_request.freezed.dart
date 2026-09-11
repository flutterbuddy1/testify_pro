// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'api_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ApiRequest _$ApiRequestFromJson(Map<String, dynamic> json) {
  return _ApiRequest.fromJson(json);
}

/// @nodoc
mixin _$ApiRequest {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get url => throw _privateConstructorUsedError;
  HttpMethod get method => throw _privateConstructorUsedError;
  Map<String, String> get headers => throw _privateConstructorUsedError;
  Map<String, String> get queryParams => throw _privateConstructorUsedError;
  String? get body => throw _privateConstructorUsedError;
  AuthConfig? get auth => throw _privateConstructorUsedError;
  int get timeoutMs => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ApiRequestCopyWith<ApiRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ApiRequestCopyWith<$Res> {
  factory $ApiRequestCopyWith(
          ApiRequest value, $Res Function(ApiRequest) then) =
      _$ApiRequestCopyWithImpl<$Res, ApiRequest>;
  @useResult
  $Res call(
      {String id,
      String name,
      String url,
      HttpMethod method,
      Map<String, String> headers,
      Map<String, String> queryParams,
      String? body,
      AuthConfig? auth,
      int timeoutMs});

  $AuthConfigCopyWith<$Res>? get auth;
}

/// @nodoc
class _$ApiRequestCopyWithImpl<$Res, $Val extends ApiRequest>
    implements $ApiRequestCopyWith<$Res> {
  _$ApiRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? url = null,
    Object? method = null,
    Object? headers = null,
    Object? queryParams = null,
    Object? body = freezed,
    Object? auth = freezed,
    Object? timeoutMs = null,
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
      url: null == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String,
      method: null == method
          ? _value.method
          : method // ignore: cast_nullable_to_non_nullable
              as HttpMethod,
      headers: null == headers
          ? _value.headers
          : headers // ignore: cast_nullable_to_non_nullable
              as Map<String, String>,
      queryParams: null == queryParams
          ? _value.queryParams
          : queryParams // ignore: cast_nullable_to_non_nullable
              as Map<String, String>,
      body: freezed == body
          ? _value.body
          : body // ignore: cast_nullable_to_non_nullable
              as String?,
      auth: freezed == auth
          ? _value.auth
          : auth // ignore: cast_nullable_to_non_nullable
              as AuthConfig?,
      timeoutMs: null == timeoutMs
          ? _value.timeoutMs
          : timeoutMs // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $AuthConfigCopyWith<$Res>? get auth {
    if (_value.auth == null) {
      return null;
    }

    return $AuthConfigCopyWith<$Res>(_value.auth!, (value) {
      return _then(_value.copyWith(auth: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ApiRequestImplCopyWith<$Res>
    implements $ApiRequestCopyWith<$Res> {
  factory _$$ApiRequestImplCopyWith(
          _$ApiRequestImpl value, $Res Function(_$ApiRequestImpl) then) =
      __$$ApiRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String url,
      HttpMethod method,
      Map<String, String> headers,
      Map<String, String> queryParams,
      String? body,
      AuthConfig? auth,
      int timeoutMs});

  @override
  $AuthConfigCopyWith<$Res>? get auth;
}

/// @nodoc
class __$$ApiRequestImplCopyWithImpl<$Res>
    extends _$ApiRequestCopyWithImpl<$Res, _$ApiRequestImpl>
    implements _$$ApiRequestImplCopyWith<$Res> {
  __$$ApiRequestImplCopyWithImpl(
      _$ApiRequestImpl _value, $Res Function(_$ApiRequestImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? url = null,
    Object? method = null,
    Object? headers = null,
    Object? queryParams = null,
    Object? body = freezed,
    Object? auth = freezed,
    Object? timeoutMs = null,
  }) {
    return _then(_$ApiRequestImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      url: null == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String,
      method: null == method
          ? _value.method
          : method // ignore: cast_nullable_to_non_nullable
              as HttpMethod,
      headers: null == headers
          ? _value._headers
          : headers // ignore: cast_nullable_to_non_nullable
              as Map<String, String>,
      queryParams: null == queryParams
          ? _value._queryParams
          : queryParams // ignore: cast_nullable_to_non_nullable
              as Map<String, String>,
      body: freezed == body
          ? _value.body
          : body // ignore: cast_nullable_to_non_nullable
              as String?,
      auth: freezed == auth
          ? _value.auth
          : auth // ignore: cast_nullable_to_non_nullable
              as AuthConfig?,
      timeoutMs: null == timeoutMs
          ? _value.timeoutMs
          : timeoutMs // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ApiRequestImpl implements _ApiRequest {
  const _$ApiRequestImpl(
      {required this.id,
      required this.name,
      required this.url,
      required this.method,
      final Map<String, String> headers = const {},
      final Map<String, String> queryParams = const {},
      this.body,
      this.auth,
      this.timeoutMs = 30000})
      : _headers = headers,
        _queryParams = queryParams;

  factory _$ApiRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$ApiRequestImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String url;
  @override
  final HttpMethod method;
  final Map<String, String> _headers;
  @override
  @JsonKey()
  Map<String, String> get headers {
    if (_headers is EqualUnmodifiableMapView) return _headers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_headers);
  }

  final Map<String, String> _queryParams;
  @override
  @JsonKey()
  Map<String, String> get queryParams {
    if (_queryParams is EqualUnmodifiableMapView) return _queryParams;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_queryParams);
  }

  @override
  final String? body;
  @override
  final AuthConfig? auth;
  @override
  @JsonKey()
  final int timeoutMs;

  @override
  String toString() {
    return 'ApiRequest(id: $id, name: $name, url: $url, method: $method, headers: $headers, queryParams: $queryParams, body: $body, auth: $auth, timeoutMs: $timeoutMs)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ApiRequestImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.method, method) || other.method == method) &&
            const DeepCollectionEquality().equals(other._headers, _headers) &&
            const DeepCollectionEquality()
                .equals(other._queryParams, _queryParams) &&
            (identical(other.body, body) || other.body == body) &&
            (identical(other.auth, auth) || other.auth == auth) &&
            (identical(other.timeoutMs, timeoutMs) ||
                other.timeoutMs == timeoutMs));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      url,
      method,
      const DeepCollectionEquality().hash(_headers),
      const DeepCollectionEquality().hash(_queryParams),
      body,
      auth,
      timeoutMs);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ApiRequestImplCopyWith<_$ApiRequestImpl> get copyWith =>
      __$$ApiRequestImplCopyWithImpl<_$ApiRequestImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ApiRequestImplToJson(
      this,
    );
  }
}

abstract class _ApiRequest implements ApiRequest {
  const factory _ApiRequest(
      {required final String id,
      required final String name,
      required final String url,
      required final HttpMethod method,
      final Map<String, String> headers,
      final Map<String, String> queryParams,
      final String? body,
      final AuthConfig? auth,
      final int timeoutMs}) = _$ApiRequestImpl;

  factory _ApiRequest.fromJson(Map<String, dynamic> json) =
      _$ApiRequestImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get url;
  @override
  HttpMethod get method;
  @override
  Map<String, String> get headers;
  @override
  Map<String, String> get queryParams;
  @override
  String? get body;
  @override
  AuthConfig? get auth;
  @override
  int get timeoutMs;
  @override
  @JsonKey(ignore: true)
  _$$ApiRequestImplCopyWith<_$ApiRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AuthConfig _$AuthConfigFromJson(Map<String, dynamic> json) {
  switch (json['runtimeType']) {
    case 'bearer':
      return BearerAuth.fromJson(json);
    case 'basic':
      return BasicAuth.fromJson(json);
    case 'apiKey':
      return ApiKeyAuth.fromJson(json);

    default:
      throw CheckedFromJsonException(json, 'runtimeType', 'AuthConfig',
          'Invalid union type "${json['runtimeType']}"!');
  }
}

/// @nodoc
mixin _$AuthConfig {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String token) bearer,
    required TResult Function(String username, String password) basic,
    required TResult Function(String key, String value, ApiKeyLocation location)
        apiKey,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String token)? bearer,
    TResult? Function(String username, String password)? basic,
    TResult? Function(String key, String value, ApiKeyLocation location)?
        apiKey,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String token)? bearer,
    TResult Function(String username, String password)? basic,
    TResult Function(String key, String value, ApiKeyLocation location)? apiKey,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(BearerAuth value) bearer,
    required TResult Function(BasicAuth value) basic,
    required TResult Function(ApiKeyAuth value) apiKey,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(BearerAuth value)? bearer,
    TResult? Function(BasicAuth value)? basic,
    TResult? Function(ApiKeyAuth value)? apiKey,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(BearerAuth value)? bearer,
    TResult Function(BasicAuth value)? basic,
    TResult Function(ApiKeyAuth value)? apiKey,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AuthConfigCopyWith<$Res> {
  factory $AuthConfigCopyWith(
          AuthConfig value, $Res Function(AuthConfig) then) =
      _$AuthConfigCopyWithImpl<$Res, AuthConfig>;
}

/// @nodoc
class _$AuthConfigCopyWithImpl<$Res, $Val extends AuthConfig>
    implements $AuthConfigCopyWith<$Res> {
  _$AuthConfigCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;
}

/// @nodoc
abstract class _$$BearerAuthImplCopyWith<$Res> {
  factory _$$BearerAuthImplCopyWith(
          _$BearerAuthImpl value, $Res Function(_$BearerAuthImpl) then) =
      __$$BearerAuthImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String token});
}

/// @nodoc
class __$$BearerAuthImplCopyWithImpl<$Res>
    extends _$AuthConfigCopyWithImpl<$Res, _$BearerAuthImpl>
    implements _$$BearerAuthImplCopyWith<$Res> {
  __$$BearerAuthImplCopyWithImpl(
      _$BearerAuthImpl _value, $Res Function(_$BearerAuthImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? token = null,
  }) {
    return _then(_$BearerAuthImpl(
      token: null == token
          ? _value.token
          : token // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BearerAuthImpl implements BearerAuth {
  const _$BearerAuthImpl({required this.token, final String? $type})
      : $type = $type ?? 'bearer';

  factory _$BearerAuthImpl.fromJson(Map<String, dynamic> json) =>
      _$$BearerAuthImplFromJson(json);

  @override
  final String token;

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString() {
    return 'AuthConfig.bearer(token: $token)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BearerAuthImpl &&
            (identical(other.token, token) || other.token == token));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, token);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$BearerAuthImplCopyWith<_$BearerAuthImpl> get copyWith =>
      __$$BearerAuthImplCopyWithImpl<_$BearerAuthImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String token) bearer,
    required TResult Function(String username, String password) basic,
    required TResult Function(String key, String value, ApiKeyLocation location)
        apiKey,
  }) {
    return bearer(token);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String token)? bearer,
    TResult? Function(String username, String password)? basic,
    TResult? Function(String key, String value, ApiKeyLocation location)?
        apiKey,
  }) {
    return bearer?.call(token);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String token)? bearer,
    TResult Function(String username, String password)? basic,
    TResult Function(String key, String value, ApiKeyLocation location)? apiKey,
    required TResult orElse(),
  }) {
    if (bearer != null) {
      return bearer(token);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(BearerAuth value) bearer,
    required TResult Function(BasicAuth value) basic,
    required TResult Function(ApiKeyAuth value) apiKey,
  }) {
    return bearer(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(BearerAuth value)? bearer,
    TResult? Function(BasicAuth value)? basic,
    TResult? Function(ApiKeyAuth value)? apiKey,
  }) {
    return bearer?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(BearerAuth value)? bearer,
    TResult Function(BasicAuth value)? basic,
    TResult Function(ApiKeyAuth value)? apiKey,
    required TResult orElse(),
  }) {
    if (bearer != null) {
      return bearer(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$BearerAuthImplToJson(
      this,
    );
  }
}

abstract class BearerAuth implements AuthConfig {
  const factory BearerAuth({required final String token}) = _$BearerAuthImpl;

  factory BearerAuth.fromJson(Map<String, dynamic> json) =
      _$BearerAuthImpl.fromJson;

  String get token;
  @JsonKey(ignore: true)
  _$$BearerAuthImplCopyWith<_$BearerAuthImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$BasicAuthImplCopyWith<$Res> {
  factory _$$BasicAuthImplCopyWith(
          _$BasicAuthImpl value, $Res Function(_$BasicAuthImpl) then) =
      __$$BasicAuthImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String username, String password});
}

/// @nodoc
class __$$BasicAuthImplCopyWithImpl<$Res>
    extends _$AuthConfigCopyWithImpl<$Res, _$BasicAuthImpl>
    implements _$$BasicAuthImplCopyWith<$Res> {
  __$$BasicAuthImplCopyWithImpl(
      _$BasicAuthImpl _value, $Res Function(_$BasicAuthImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? username = null,
    Object? password = null,
  }) {
    return _then(_$BasicAuthImpl(
      username: null == username
          ? _value.username
          : username // ignore: cast_nullable_to_non_nullable
              as String,
      password: null == password
          ? _value.password
          : password // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BasicAuthImpl implements BasicAuth {
  const _$BasicAuthImpl(
      {required this.username, required this.password, final String? $type})
      : $type = $type ?? 'basic';

  factory _$BasicAuthImpl.fromJson(Map<String, dynamic> json) =>
      _$$BasicAuthImplFromJson(json);

  @override
  final String username;
  @override
  final String password;

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString() {
    return 'AuthConfig.basic(username: $username, password: $password)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BasicAuthImpl &&
            (identical(other.username, username) ||
                other.username == username) &&
            (identical(other.password, password) ||
                other.password == password));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, username, password);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$BasicAuthImplCopyWith<_$BasicAuthImpl> get copyWith =>
      __$$BasicAuthImplCopyWithImpl<_$BasicAuthImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String token) bearer,
    required TResult Function(String username, String password) basic,
    required TResult Function(String key, String value, ApiKeyLocation location)
        apiKey,
  }) {
    return basic(username, password);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String token)? bearer,
    TResult? Function(String username, String password)? basic,
    TResult? Function(String key, String value, ApiKeyLocation location)?
        apiKey,
  }) {
    return basic?.call(username, password);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String token)? bearer,
    TResult Function(String username, String password)? basic,
    TResult Function(String key, String value, ApiKeyLocation location)? apiKey,
    required TResult orElse(),
  }) {
    if (basic != null) {
      return basic(username, password);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(BearerAuth value) bearer,
    required TResult Function(BasicAuth value) basic,
    required TResult Function(ApiKeyAuth value) apiKey,
  }) {
    return basic(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(BearerAuth value)? bearer,
    TResult? Function(BasicAuth value)? basic,
    TResult? Function(ApiKeyAuth value)? apiKey,
  }) {
    return basic?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(BearerAuth value)? bearer,
    TResult Function(BasicAuth value)? basic,
    TResult Function(ApiKeyAuth value)? apiKey,
    required TResult orElse(),
  }) {
    if (basic != null) {
      return basic(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$BasicAuthImplToJson(
      this,
    );
  }
}

abstract class BasicAuth implements AuthConfig {
  const factory BasicAuth(
      {required final String username,
      required final String password}) = _$BasicAuthImpl;

  factory BasicAuth.fromJson(Map<String, dynamic> json) =
      _$BasicAuthImpl.fromJson;

  String get username;
  String get password;
  @JsonKey(ignore: true)
  _$$BasicAuthImplCopyWith<_$BasicAuthImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ApiKeyAuthImplCopyWith<$Res> {
  factory _$$ApiKeyAuthImplCopyWith(
          _$ApiKeyAuthImpl value, $Res Function(_$ApiKeyAuthImpl) then) =
      __$$ApiKeyAuthImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String key, String value, ApiKeyLocation location});
}

/// @nodoc
class __$$ApiKeyAuthImplCopyWithImpl<$Res>
    extends _$AuthConfigCopyWithImpl<$Res, _$ApiKeyAuthImpl>
    implements _$$ApiKeyAuthImplCopyWith<$Res> {
  __$$ApiKeyAuthImplCopyWithImpl(
      _$ApiKeyAuthImpl _value, $Res Function(_$ApiKeyAuthImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? key = null,
    Object? value = null,
    Object? location = null,
  }) {
    return _then(_$ApiKeyAuthImpl(
      key: null == key
          ? _value.key
          : key // ignore: cast_nullable_to_non_nullable
              as String,
      value: null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as String,
      location: null == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as ApiKeyLocation,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ApiKeyAuthImpl implements ApiKeyAuth {
  const _$ApiKeyAuthImpl(
      {required this.key,
      required this.value,
      this.location = ApiKeyLocation.header,
      final String? $type})
      : $type = $type ?? 'apiKey';

  factory _$ApiKeyAuthImpl.fromJson(Map<String, dynamic> json) =>
      _$$ApiKeyAuthImplFromJson(json);

  @override
  final String key;
  @override
  final String value;
  @override
  @JsonKey()
  final ApiKeyLocation location;

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString() {
    return 'AuthConfig.apiKey(key: $key, value: $value, location: $location)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ApiKeyAuthImpl &&
            (identical(other.key, key) || other.key == key) &&
            (identical(other.value, value) || other.value == value) &&
            (identical(other.location, location) ||
                other.location == location));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, key, value, location);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ApiKeyAuthImplCopyWith<_$ApiKeyAuthImpl> get copyWith =>
      __$$ApiKeyAuthImplCopyWithImpl<_$ApiKeyAuthImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String token) bearer,
    required TResult Function(String username, String password) basic,
    required TResult Function(String key, String value, ApiKeyLocation location)
        apiKey,
  }) {
    return apiKey(key, value, location);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String token)? bearer,
    TResult? Function(String username, String password)? basic,
    TResult? Function(String key, String value, ApiKeyLocation location)?
        apiKey,
  }) {
    return apiKey?.call(key, value, location);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String token)? bearer,
    TResult Function(String username, String password)? basic,
    TResult Function(String key, String value, ApiKeyLocation location)? apiKey,
    required TResult orElse(),
  }) {
    if (apiKey != null) {
      return apiKey(key, value, location);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(BearerAuth value) bearer,
    required TResult Function(BasicAuth value) basic,
    required TResult Function(ApiKeyAuth value) apiKey,
  }) {
    return apiKey(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(BearerAuth value)? bearer,
    TResult? Function(BasicAuth value)? basic,
    TResult? Function(ApiKeyAuth value)? apiKey,
  }) {
    return apiKey?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(BearerAuth value)? bearer,
    TResult Function(BasicAuth value)? basic,
    TResult Function(ApiKeyAuth value)? apiKey,
    required TResult orElse(),
  }) {
    if (apiKey != null) {
      return apiKey(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$ApiKeyAuthImplToJson(
      this,
    );
  }
}

abstract class ApiKeyAuth implements AuthConfig {
  const factory ApiKeyAuth(
      {required final String key,
      required final String value,
      final ApiKeyLocation location}) = _$ApiKeyAuthImpl;

  factory ApiKeyAuth.fromJson(Map<String, dynamic> json) =
      _$ApiKeyAuthImpl.fromJson;

  String get key;
  String get value;
  ApiKeyLocation get location;
  @JsonKey(ignore: true)
  _$$ApiKeyAuthImplCopyWith<_$ApiKeyAuthImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
