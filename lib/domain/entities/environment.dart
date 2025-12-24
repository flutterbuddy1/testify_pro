import 'package:freezed_annotation/freezed_annotation.dart';

part 'environment.freezed.dart';
part 'environment.g.dart';

@freezed
class Environment with _$Environment {
  const factory Environment({
    required String id,
    required String name,
    @Default({}) Map<String, String> variables,
    @Default(false) bool isActive,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Environment;

  factory Environment.fromJson(Map<String, dynamic> json) =>
      _$EnvironmentFromJson(json);
}
