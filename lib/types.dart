import 'package:meta/meta.dart';
import 'package:recase/recase.dart';

class Field {
  final String name;
  final String format;
  final String path;
  final int minLength;
  final int maxLength;
  final List enumValues;
  final int maximum;
  final int minimum;
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
      int minLength: null,
      int maxLength: null,
      int minimum: null,
      int maximum: null,
      enumValues: null,
      bool isRequired = false,
      String path = '/'})
      : name = name,
        type = type,
        format = format,
        minLength = minLength,
        maxLength = maxLength,
        minimum = minimum,
        maximum = maximum,
        enumValues = enumValues,
        isRequired = isRequired,
        path = path;
}

class SchemaType {
  final String key;
  final String name;
  final List<Field> fields;

  const SchemaType._internal(this.name, this.key, this.fields);

  factory SchemaType(String name) {
    return SchemaType._internal(
      ReCase(name).pascalCase,
      name,
      []
    );
  }

  Field getField(String name) => fields.firstWhere((f) => f.name == name);
}

class ContainerType implements SchemaType {
  final String _name;
  final String _key;
  SchemaType _innerType;

  ContainerType._internal(this._name, this._key, this._innerType);

  factory ContainerType(String name, SchemaType inner) {
    return ContainerType._internal(
        ReCase(name).pascalCase ,
        name,
        inner
    );
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
