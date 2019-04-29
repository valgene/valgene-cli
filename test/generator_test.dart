import 'package:test/test.dart';
import 'package:valgene_cli/generator.dart';
import 'package:valgene_cli/types.dart';

void main() {
  group('FieldCodeArtifact.enumValues', () {
    test("strings", () {
      final a = FieldCodeArtifact(Field(
          name: 'foo',
          type: OpenApiPrimitives.string,
          enumValues: ['A', 'B', 'C']));

      expect(a.isNumber, isFalse);
      expect(a.isString, isTrue);
      expect(a.enumValues, equals('["A", "B", "C"]'));
    });

    test("integers", () {
      final a = FieldCodeArtifact(Field(
          name: 'foo', type: OpenApiPrimitives.integer, enumValues: [1, 2, 3]));

      expect(a.isNumber, isTrue);
      expect(a.enumValues, equals('[1, 2, 3]'));
    });

    test("booleans", () {
      final a = FieldCodeArtifact(Field(
          name: 'foo',
          type: OpenApiPrimitives.boolean,
          enumValues: [true, false]));

      expect(a.isBoolean, isTrue);
      expect(a.enumValues, equals('[true, false]'));
    });
  });

  group('FieldCodeArtifact.defaultValue', () {
    test("string", () {
      final a = FieldCodeArtifact(Field(
          name: 'foo', type: OpenApiPrimitives.string, defaultValue: 'Foo'));

      expect(a.isString, isTrue);
      expect(a.defaultValue, equals('"Foo"'));
      expect(a.hasDefault, isTrue);
    });

    test("boolean", () {
      final a = FieldCodeArtifact(Field(
          name: 'foo', type: OpenApiPrimitives.boolean, defaultValue: false));

      expect(a.isBoolean, isTrue);
      expect(a.defaultValue, isFalse);
      expect(a.hasDefault, isTrue);
    });

    test("float", () {
      final a = FieldCodeArtifact(
          Field(name: 'foo', type: OpenApiPrimitives.number, defaultValue: .6));

      expect(a.isNumber, isTrue);
      expect(a.defaultValue, .6);
      expect(a.hasDefault, isTrue);
    });

    test("null", () {
      final a = FieldCodeArtifact(Field(
          name: 'foo', type: OpenApiPrimitives.number, defaultValue: null));

      expect(a.isNumber, isTrue);
      expect(a.defaultValue, 'null');
      expect(a.hasDefault, isTrue);
    });

    test("NoDefault", () {
      final a = FieldCodeArtifact(Field(
          name: 'foo',
          type: OpenApiPrimitives.number,
          defaultValue: NoDefault()));

      expect(a.isNumber, isTrue);
      expect(a.defaultValue, TypeMatcher<NoDefault>());
      expect(a.hasDefault, isFalse);
    });
  });

  group('FieldCodeArtifact.nullable', () {
    test("default case", () {
      final a =
          FieldCodeArtifact(Field(name: 'foo', type: OpenApiPrimitives.string));

      expect(a.isString, isTrue);
      expect(a.isNullable, isFalse);
    });
    test("string", () {
      final a = FieldCodeArtifact(
          Field(name: 'foo', type: OpenApiPrimitives.string, nullable: true));

      expect(a.isString, isTrue);
      expect(a.isNullable, isTrue);
    });
  });

  group('FieldCodeArtifact tests', () {
    test("other members values", () {
      final f = Field(name: 'foo', type: OpenApiPrimitives.integer);
      final a = FieldCodeArtifact(f);

      expect(a.validationMethodName, equals('isFooFieldValid'));
      expect(a.asConst, equals('PROPERTY_FOO'));
      expect(a.asProperty, equals('foo'));
    });

    test("integer", () {
      final f = Field(name: 'foo', type: OpenApiPrimitives.integer);
      final a = FieldCodeArtifact(f);

      expect(a.isNumber, isTrue);
      expect(a.isString, isFalse);
      expect(a.isBoolean, isFalse);
    });

    test("boolean", () {
      final a = FieldCodeArtifact(
          Field(name: 'foo', type: OpenApiPrimitives.boolean));

      expect(a.isNumber, isFalse);
      expect(a.isString, isFalse);
      expect(a.isBoolean, isTrue);
    });
  });

  group('Typed Languages Adaption', () {
    test('Java integers', () {
      final f = Field(name: 'foo', type: OpenApiPrimitives.integer);
      final java = JavaTypes.of(f);

      expect(java.nativeName, equals('int'));
      expect(java.fqcn, equals('java.lang.Integer'));
      expect(java.className, equals('Integer'));
    });
    test('Java longs', () {
      final f =
          Field(name: 'foo', type: OpenApiPrimitives.integer, format: 'int64');
      final java = JavaTypes.of(f);

      expect(java.nativeName, equals('long'));
      expect(java.fqcn, equals('java.lang.Long'));
      expect(java.className, equals('Long'));
    });
  });
}

class StaticType {
  final String nativeName;
  final String className;
  final String fqcn;

  StaticType(this.nativeName, this.className, this.fqcn);
}

class JavaTypes {
  static final StaticType int =
      StaticType('int', 'Integer', 'java.lang.Integer');
  static final StaticType long = StaticType('long', 'Long', 'java.lang.Long');

  static StaticType of(Field f) {
    switch (f.type) {
      case 'integer':
        if (f.format == 'int64') {
          return long;
        }
        return int;
    }
  }
}
