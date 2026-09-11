// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'flow_step.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

FlowStep _$FlowStepFromJson(Map<String, dynamic> json) {
  return _FlowStep.fromJson(json);
}

/// @nodoc
mixin _$FlowStep {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  ApiRequest get request => throw _privateConstructorUsedError;

  /// JSONPath extractors to extract data from response
  /// Format: {"variableName": "$.path.to.value"}
  Map<String, String> get extractors => throw _privateConstructorUsedError;

  /// Assertions to validate response
  List<Assertion> get assertions => throw _privateConstructorUsedError;

  /// Think time in milliseconds (simulates user delay before next step)
  int get thinkTimeMs => throw _privateConstructorUsedError;

  /// Stop flow if this step fails
  bool get stopOnFailure => throw _privateConstructorUsedError;

  /// Enable this step
  bool get enabled => throw _privateConstructorUsedError;

  /// Optional pre-request script executed before the HTTP call
  String? get preRequestScript => throw _privateConstructorUsedError;

  /// Optional test script executed after the response is received
  String? get testScript => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $FlowStepCopyWith<FlowStep> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FlowStepCopyWith<$Res> {
  factory $FlowStepCopyWith(FlowStep value, $Res Function(FlowStep) then) =
      _$FlowStepCopyWithImpl<$Res, FlowStep>;
  @useResult
  $Res call(
      {String id,
      String name,
      ApiRequest request,
      Map<String, String> extractors,
      List<Assertion> assertions,
      int thinkTimeMs,
      bool stopOnFailure,
      bool enabled,
      String? preRequestScript,
      String? testScript});

  $ApiRequestCopyWith<$Res> get request;
}

/// @nodoc
class _$FlowStepCopyWithImpl<$Res, $Val extends FlowStep>
    implements $FlowStepCopyWith<$Res> {
  _$FlowStepCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? request = null,
    Object? extractors = null,
    Object? assertions = null,
    Object? thinkTimeMs = null,
    Object? stopOnFailure = null,
    Object? enabled = null,
    Object? preRequestScript = freezed,
    Object? testScript = freezed,
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
      request: null == request
          ? _value.request
          : request // ignore: cast_nullable_to_non_nullable
              as ApiRequest,
      extractors: null == extractors
          ? _value.extractors
          : extractors // ignore: cast_nullable_to_non_nullable
              as Map<String, String>,
      assertions: null == assertions
          ? _value.assertions
          : assertions // ignore: cast_nullable_to_non_nullable
              as List<Assertion>,
      thinkTimeMs: null == thinkTimeMs
          ? _value.thinkTimeMs
          : thinkTimeMs // ignore: cast_nullable_to_non_nullable
              as int,
      stopOnFailure: null == stopOnFailure
          ? _value.stopOnFailure
          : stopOnFailure // ignore: cast_nullable_to_non_nullable
              as bool,
      enabled: null == enabled
          ? _value.enabled
          : enabled // ignore: cast_nullable_to_non_nullable
              as bool,
      preRequestScript: freezed == preRequestScript
          ? _value.preRequestScript
          : preRequestScript // ignore: cast_nullable_to_non_nullable
              as String?,
      testScript: freezed == testScript
          ? _value.testScript
          : testScript // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $ApiRequestCopyWith<$Res> get request {
    return $ApiRequestCopyWith<$Res>(_value.request, (value) {
      return _then(_value.copyWith(request: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$FlowStepImplCopyWith<$Res>
    implements $FlowStepCopyWith<$Res> {
  factory _$$FlowStepImplCopyWith(
          _$FlowStepImpl value, $Res Function(_$FlowStepImpl) then) =
      __$$FlowStepImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      ApiRequest request,
      Map<String, String> extractors,
      List<Assertion> assertions,
      int thinkTimeMs,
      bool stopOnFailure,
      bool enabled,
      String? preRequestScript,
      String? testScript});

  @override
  $ApiRequestCopyWith<$Res> get request;
}

/// @nodoc
class __$$FlowStepImplCopyWithImpl<$Res>
    extends _$FlowStepCopyWithImpl<$Res, _$FlowStepImpl>
    implements _$$FlowStepImplCopyWith<$Res> {
  __$$FlowStepImplCopyWithImpl(
      _$FlowStepImpl _value, $Res Function(_$FlowStepImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? request = null,
    Object? extractors = null,
    Object? assertions = null,
    Object? thinkTimeMs = null,
    Object? stopOnFailure = null,
    Object? enabled = null,
    Object? preRequestScript = freezed,
    Object? testScript = freezed,
  }) {
    return _then(_$FlowStepImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      request: null == request
          ? _value.request
          : request // ignore: cast_nullable_to_non_nullable
              as ApiRequest,
      extractors: null == extractors
          ? _value._extractors
          : extractors // ignore: cast_nullable_to_non_nullable
              as Map<String, String>,
      assertions: null == assertions
          ? _value._assertions
          : assertions // ignore: cast_nullable_to_non_nullable
              as List<Assertion>,
      thinkTimeMs: null == thinkTimeMs
          ? _value.thinkTimeMs
          : thinkTimeMs // ignore: cast_nullable_to_non_nullable
              as int,
      stopOnFailure: null == stopOnFailure
          ? _value.stopOnFailure
          : stopOnFailure // ignore: cast_nullable_to_non_nullable
              as bool,
      enabled: null == enabled
          ? _value.enabled
          : enabled // ignore: cast_nullable_to_non_nullable
              as bool,
      preRequestScript: freezed == preRequestScript
          ? _value.preRequestScript
          : preRequestScript // ignore: cast_nullable_to_non_nullable
              as String?,
      testScript: freezed == testScript
          ? _value.testScript
          : testScript // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$FlowStepImpl implements _FlowStep {
  const _$FlowStepImpl(
      {required this.id,
      required this.name,
      required this.request,
      final Map<String, String> extractors = const {},
      final List<Assertion> assertions = const [],
      this.thinkTimeMs = 0,
      this.stopOnFailure = true,
      this.enabled = true,
      this.preRequestScript,
      this.testScript})
      : _extractors = extractors,
        _assertions = assertions;

  factory _$FlowStepImpl.fromJson(Map<String, dynamic> json) =>
      _$$FlowStepImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final ApiRequest request;

  /// JSONPath extractors to extract data from response
  /// Format: {"variableName": "$.path.to.value"}
  final Map<String, String> _extractors;

  /// JSONPath extractors to extract data from response
  /// Format: {"variableName": "$.path.to.value"}
  @override
  @JsonKey()
  Map<String, String> get extractors {
    if (_extractors is EqualUnmodifiableMapView) return _extractors;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_extractors);
  }

  /// Assertions to validate response
  final List<Assertion> _assertions;

  /// Assertions to validate response
  @override
  @JsonKey()
  List<Assertion> get assertions {
    if (_assertions is EqualUnmodifiableListView) return _assertions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_assertions);
  }

  /// Think time in milliseconds (simulates user delay before next step)
  @override
  @JsonKey()
  final int thinkTimeMs;

  /// Stop flow if this step fails
  @override
  @JsonKey()
  final bool stopOnFailure;

  /// Enable this step
  @override
  @JsonKey()
  final bool enabled;

  /// Optional pre-request script executed before the HTTP call
  @override
  final String? preRequestScript;

  /// Optional test script executed after the response is received
  @override
  final String? testScript;

  @override
  String toString() {
    return 'FlowStep(id: $id, name: $name, request: $request, extractors: $extractors, assertions: $assertions, thinkTimeMs: $thinkTimeMs, stopOnFailure: $stopOnFailure, enabled: $enabled, preRequestScript: $preRequestScript, testScript: $testScript)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FlowStepImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.request, request) || other.request == request) &&
            const DeepCollectionEquality()
                .equals(other._extractors, _extractors) &&
            const DeepCollectionEquality()
                .equals(other._assertions, _assertions) &&
            (identical(other.thinkTimeMs, thinkTimeMs) ||
                other.thinkTimeMs == thinkTimeMs) &&
            (identical(other.stopOnFailure, stopOnFailure) ||
                other.stopOnFailure == stopOnFailure) &&
            (identical(other.enabled, enabled) || other.enabled == enabled) &&
            (identical(other.preRequestScript, preRequestScript) ||
                other.preRequestScript == preRequestScript) &&
            (identical(other.testScript, testScript) ||
                other.testScript == testScript));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      request,
      const DeepCollectionEquality().hash(_extractors),
      const DeepCollectionEquality().hash(_assertions),
      thinkTimeMs,
      stopOnFailure,
      enabled,
      preRequestScript,
      testScript);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$FlowStepImplCopyWith<_$FlowStepImpl> get copyWith =>
      __$$FlowStepImplCopyWithImpl<_$FlowStepImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FlowStepImplToJson(
      this,
    );
  }
}

abstract class _FlowStep implements FlowStep {
  const factory _FlowStep(
      {required final String id,
      required final String name,
      required final ApiRequest request,
      final Map<String, String> extractors,
      final List<Assertion> assertions,
      final int thinkTimeMs,
      final bool stopOnFailure,
      final bool enabled,
      final String? preRequestScript,
      final String? testScript}) = _$FlowStepImpl;

  factory _FlowStep.fromJson(Map<String, dynamic> json) =
      _$FlowStepImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  ApiRequest get request;
  @override

  /// JSONPath extractors to extract data from response
  /// Format: {"variableName": "$.path.to.value"}
  Map<String, String> get extractors;
  @override

  /// Assertions to validate response
  List<Assertion> get assertions;
  @override

  /// Think time in milliseconds (simulates user delay before next step)
  int get thinkTimeMs;
  @override

  /// Stop flow if this step fails
  bool get stopOnFailure;
  @override

  /// Enable this step
  bool get enabled;
  @override

  /// Optional pre-request script executed before the HTTP call
  String? get preRequestScript;
  @override

  /// Optional test script executed after the response is received
  String? get testScript;
  @override
  @JsonKey(ignore: true)
  _$$FlowStepImplCopyWith<_$FlowStepImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Assertion _$AssertionFromJson(Map<String, dynamic> json) {
  return _Assertion.fromJson(json);
}

/// @nodoc
mixin _$Assertion {
  String get name => throw _privateConstructorUsedError;
  AssertionType get type => throw _privateConstructorUsedError;
  String get expected => throw _privateConstructorUsedError;
  String? get actual => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $AssertionCopyWith<Assertion> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AssertionCopyWith<$Res> {
  factory $AssertionCopyWith(Assertion value, $Res Function(Assertion) then) =
      _$AssertionCopyWithImpl<$Res, Assertion>;
  @useResult
  $Res call({String name, AssertionType type, String expected, String? actual});
}

/// @nodoc
class _$AssertionCopyWithImpl<$Res, $Val extends Assertion>
    implements $AssertionCopyWith<$Res> {
  _$AssertionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? type = null,
    Object? expected = null,
    Object? actual = freezed,
  }) {
    return _then(_value.copyWith(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as AssertionType,
      expected: null == expected
          ? _value.expected
          : expected // ignore: cast_nullable_to_non_nullable
              as String,
      actual: freezed == actual
          ? _value.actual
          : actual // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AssertionImplCopyWith<$Res>
    implements $AssertionCopyWith<$Res> {
  factory _$$AssertionImplCopyWith(
          _$AssertionImpl value, $Res Function(_$AssertionImpl) then) =
      __$$AssertionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String name, AssertionType type, String expected, String? actual});
}

/// @nodoc
class __$$AssertionImplCopyWithImpl<$Res>
    extends _$AssertionCopyWithImpl<$Res, _$AssertionImpl>
    implements _$$AssertionImplCopyWith<$Res> {
  __$$AssertionImplCopyWithImpl(
      _$AssertionImpl _value, $Res Function(_$AssertionImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? type = null,
    Object? expected = null,
    Object? actual = freezed,
  }) {
    return _then(_$AssertionImpl(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as AssertionType,
      expected: null == expected
          ? _value.expected
          : expected // ignore: cast_nullable_to_non_nullable
              as String,
      actual: freezed == actual
          ? _value.actual
          : actual // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AssertionImpl implements _Assertion {
  const _$AssertionImpl(
      {required this.name,
      required this.type,
      required this.expected,
      this.actual});

  factory _$AssertionImpl.fromJson(Map<String, dynamic> json) =>
      _$$AssertionImplFromJson(json);

  @override
  final String name;
  @override
  final AssertionType type;
  @override
  final String expected;
  @override
  final String? actual;

  @override
  String toString() {
    return 'Assertion(name: $name, type: $type, expected: $expected, actual: $actual)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AssertionImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.expected, expected) ||
                other.expected == expected) &&
            (identical(other.actual, actual) || other.actual == actual));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, name, type, expected, actual);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AssertionImplCopyWith<_$AssertionImpl> get copyWith =>
      __$$AssertionImplCopyWithImpl<_$AssertionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AssertionImplToJson(
      this,
    );
  }
}

abstract class _Assertion implements Assertion {
  const factory _Assertion(
      {required final String name,
      required final AssertionType type,
      required final String expected,
      final String? actual}) = _$AssertionImpl;

  factory _Assertion.fromJson(Map<String, dynamic> json) =
      _$AssertionImpl.fromJson;

  @override
  String get name;
  @override
  AssertionType get type;
  @override
  String get expected;
  @override
  String? get actual;
  @override
  @JsonKey(ignore: true)
  _$$AssertionImplCopyWith<_$AssertionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
