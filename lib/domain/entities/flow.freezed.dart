// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'flow.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Flow _$FlowFromJson(Map<String, dynamic> json) {
  return _Flow.fromJson(json);
}

/// @nodoc
mixin _$Flow {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  List<FlowStep> get steps => throw _privateConstructorUsedError;

  /// Global variables available to all steps
  Map<String, String> get variables => throw _privateConstructorUsedError;

  /// Tags for organization
  List<String> get tags => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this Flow to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Flow
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FlowCopyWith<Flow> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FlowCopyWith<$Res> {
  factory $FlowCopyWith(Flow value, $Res Function(Flow) then) =
      _$FlowCopyWithImpl<$Res, Flow>;
  @useResult
  $Res call(
      {String id,
      String name,
      String? description,
      List<FlowStep> steps,
      Map<String, String> variables,
      List<String> tags,
      DateTime createdAt,
      DateTime updatedAt});
}

/// @nodoc
class _$FlowCopyWithImpl<$Res, $Val extends Flow>
    implements $FlowCopyWith<$Res> {
  _$FlowCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Flow
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = freezed,
    Object? steps = null,
    Object? variables = null,
    Object? tags = null,
    Object? createdAt = null,
    Object? updatedAt = null,
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
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      steps: null == steps
          ? _value.steps
          : steps // ignore: cast_nullable_to_non_nullable
              as List<FlowStep>,
      variables: null == variables
          ? _value.variables
          : variables // ignore: cast_nullable_to_non_nullable
              as Map<String, String>,
      tags: null == tags
          ? _value.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$FlowImplCopyWith<$Res> implements $FlowCopyWith<$Res> {
  factory _$$FlowImplCopyWith(
          _$FlowImpl value, $Res Function(_$FlowImpl) then) =
      __$$FlowImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String? description,
      List<FlowStep> steps,
      Map<String, String> variables,
      List<String> tags,
      DateTime createdAt,
      DateTime updatedAt});
}

/// @nodoc
class __$$FlowImplCopyWithImpl<$Res>
    extends _$FlowCopyWithImpl<$Res, _$FlowImpl>
    implements _$$FlowImplCopyWith<$Res> {
  __$$FlowImplCopyWithImpl(_$FlowImpl _value, $Res Function(_$FlowImpl) _then)
      : super(_value, _then);

  /// Create a copy of Flow
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = freezed,
    Object? steps = null,
    Object? variables = null,
    Object? tags = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_$FlowImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      steps: null == steps
          ? _value._steps
          : steps // ignore: cast_nullable_to_non_nullable
              as List<FlowStep>,
      variables: null == variables
          ? _value._variables
          : variables // ignore: cast_nullable_to_non_nullable
              as Map<String, String>,
      tags: null == tags
          ? _value._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$FlowImpl implements _Flow {
  const _$FlowImpl(
      {required this.id,
      required this.name,
      this.description,
      required final List<FlowStep> steps,
      final Map<String, String> variables = const {},
      final List<String> tags = const [],
      required this.createdAt,
      required this.updatedAt})
      : _steps = steps,
        _variables = variables,
        _tags = tags;

  factory _$FlowImpl.fromJson(Map<String, dynamic> json) =>
      _$$FlowImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String? description;
  final List<FlowStep> _steps;
  @override
  List<FlowStep> get steps {
    if (_steps is EqualUnmodifiableListView) return _steps;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_steps);
  }

  /// Global variables available to all steps
  final Map<String, String> _variables;

  /// Global variables available to all steps
  @override
  @JsonKey()
  Map<String, String> get variables {
    if (_variables is EqualUnmodifiableMapView) return _variables;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_variables);
  }

  /// Tags for organization
  final List<String> _tags;

  /// Tags for organization
  @override
  @JsonKey()
  List<String> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'Flow(id: $id, name: $name, description: $description, steps: $steps, variables: $variables, tags: $tags, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FlowImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality().equals(other._steps, _steps) &&
            const DeepCollectionEquality()
                .equals(other._variables, _variables) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      description,
      const DeepCollectionEquality().hash(_steps),
      const DeepCollectionEquality().hash(_variables),
      const DeepCollectionEquality().hash(_tags),
      createdAt,
      updatedAt);

  /// Create a copy of Flow
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FlowImplCopyWith<_$FlowImpl> get copyWith =>
      __$$FlowImplCopyWithImpl<_$FlowImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FlowImplToJson(
      this,
    );
  }
}

abstract class _Flow implements Flow {
  const factory _Flow(
      {required final String id,
      required final String name,
      final String? description,
      required final List<FlowStep> steps,
      final Map<String, String> variables,
      final List<String> tags,
      required final DateTime createdAt,
      required final DateTime updatedAt}) = _$FlowImpl;

  factory _Flow.fromJson(Map<String, dynamic> json) = _$FlowImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String? get description;
  @override
  List<FlowStep> get steps;

  /// Global variables available to all steps
  @override
  Map<String, String> get variables;

  /// Tags for organization
  @override
  List<String> get tags;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;

  /// Create a copy of Flow
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FlowImplCopyWith<_$FlowImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
