import 'package:meta/meta.dart';

class Field {
  final String name;
  final String type;
  final String format;
  final String path;
  final int minLength;
  final int maxLength;
  final List enumValues;
  final int maximum;
  final int minimum;
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
