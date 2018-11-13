import 'package:test/test.dart';
import 'package:valgene_cli/generator.dart';
import 'package:valgene_cli/types.dart';

void main() {
  test("File.constructor with absent defaults", () {
    final f = Field(name: 'foo', type: 'integer');
    final a = FieldCodeArtifact(f);

    expect(a.isNumber, isTrue);
    expect(a.isString, isFalse);
    expect(a.isBoolean, isFalse);
    expect(a.validationMethodName, equals('isFooValid'));
    expect(a.asConst, equals('PROPERTY_FOO'));
    expect(a.asProperty, equals('foo'));
  });
}
