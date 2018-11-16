import 'package:test/test.dart';
import 'package:valgene_cli/generator.dart';
import 'package:valgene_cli/types.dart';

void main() {
  group('FieldCodeArtifact tests', () {
    test("FieldCodeArtifact for integer", () {
      final f = Field(name: 'foo', type: 'integer');
      final a = FieldCodeArtifact(f);

      expect(a.isNumber, isTrue);
      expect(a.isString, isFalse);
      expect(a.isBoolean, isFalse);
      expect(a.validationMethodName, equals('isFooValid'));
      expect(a.asConst, equals('PROPERTY_FOO'));
      expect(a.asProperty, equals('foo'));
    });
  });

  group('Typed Languages Adaption', () {
    test('Java integers', () {
      final f = Field(name: 'foo', type: 'integer');
      final java = JavaTypes.of(f);

      expect(java.nativeName, equals('int'));
      expect(java.fqcn, equals('java.lang.Integer'));
      expect(java.className, equals('Integer'));
    });
    test('Java longs', () {
      final f = Field(name: 'foo', type: 'integer', format: 'int64');
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
  static final StaticType int = StaticType('int', 'Integer', 'java.lang.Integer');
  static final StaticType long = StaticType('long', 'Long', 'java.lang.Long');

  static StaticType of(Field f) {
    switch(f.type) {
      case 'integer':
        if(f.format == 'int64') {
          return long;
        }
        return int;
    }
  }
}
