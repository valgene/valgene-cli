import 'package:meta/meta.dart';

class Field {
  final String name;
  final String type;
  final String path;
  final int minLength;

  bool get hasMinLength => minLength != null;
  final int maxLength;

  bool get hasMaxLength => maxLength != null;
  final int minimum;

  bool get hasMinimum => minimum != null;
  final int maximum;

  bool get hasMaximum => maximum != null;
  final List enumValues;

  bool get hasEnumValues => enumValues != null;
  bool isRequired;

  Field(
      {@required String name,
      @required String type,
      int minLength: null,
      int maxLength: null,
      int minimum: null,
      int maximum: null,
      enumValues: null,
      bool isRequired = false,
      String path = '/'})
      : name = name,
        type = type,
        minLength = minLength,
        maxLength = maxLength,
        minimum = minimum,
        maximum = maximum,
        enumValues = enumValues,
        isRequired = isRequired,
        path = path;
}

class SchemaType {
  final String name;
  final List<Field> fields;

  SchemaType(this.name, this.fields);
}

class ContainerType implements SchemaType {
  final String _name;
  final SchemaType _innerType;

  ContainerType(this._name, this._innerType);

  @override
  List<Field> get fields => [];

  @override
  String get name => _name;

  SchemaType get innerType => _innerType;
}
