import 'package:test/test.dart';
import 'package:valgene_cli/types.dart';

void main() {
  test("Field.constructor with absent defaults", () {
    var f = Field(name: 'foo', type: OpenApiPrimitives.number);
    expect(f.name, equals('foo'));
    expect(f.maxLength, isNull);
    expect(f.hasMaxLength, isFalse);
    expect(f.hasMinLength, isFalse);
    expect(f.hasEnumValues, isFalse);
    expect(f.hasMaximum, isFalse);
    expect(f.hasMinimum, isFalse);
    expect(f.defaultValue, isNull);
  });
}
