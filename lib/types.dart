import 'package:meta/meta.dart';
import 'package:recase/recase.dart';

/// defines the primitive types of
/// [JSON Schema](https://tools.ietf.org/html/draft-wright-json-schema-00#section-4.2)
/// and
/// [OpenAPI spec](https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.2.md#schemaObject)
class OpenApiPrimitives {
  static const String string = 'string';
  static const String integer = 'integer';
  static const String number = 'number';
  static const String boolean = 'boolean';
  static const String object = 'object';
  static const String array = 'array';
}

class Field {
  final String name;
  final String format;
  final String path;
  final int minLength;
  final int maxLength;
  final List enumValues;
  final int maximum;
  final int minimum;
  final dynamic defaultValue;
  final bool nullable;
  String type;
  bool isRequired;

  bool get hasMinLength => minLength != null;
  bool get hasMaxLength => maxLength != null;
  bool get hasMinimum => minimum != null;
  bool get hasMaximum => maximum != null;
  bool get hasEnumValues => enumValues != null;

  Field(
      {@required String name,
      @required String type,
      String format,
      int minLength,
      int maxLength,
      int minimum,
      int maximum,
      enumValues,
      bool isRequired = false,
      String path = '/',
      dynamic defaultValue,
      this.nullable = false})
      : name = name,
        type = type,
        format = format,
        minLength = minLength,
        maxLength = maxLength,
        minimum = minimum,
        maximum = maximum,
        enumValues = enumValues,
        isRequired = isRequired,
        path = path,
        defaultValue = defaultValue;
}

class NoDefault {}

class SchemaType {
  final String key;
  final String name;
  final List<Field> fields;

  const SchemaType._internal(this.name, this.key, this.fields);

  factory SchemaType(String name) {
    return SchemaType._internal(ReCase(name).pascalCase, name, []);
  }

  Field getField(String name) => fields.firstWhere((f) => f.name == name);
}

class ContainerType implements SchemaType {
  final String _name;
  final String _key;
  SchemaType _innerType;

  ContainerType._internal(this._name, this._key, this._innerType);

  factory ContainerType(String name, SchemaType inner) {
    return ContainerType._internal(ReCase(name).pascalCase, name, inner);
  }

  @override
  List<Field> get fields => [];

  @override
  String get name => _name;

  @override
  String get key => _key;

  SchemaType get innerType => _innerType;
  set innerType(SchemaType value) {
    _innerType = value;
  }

  @override
  Field getField(String name) => _innerType.getField(name);
}
