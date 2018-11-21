import 'package:test/test.dart';
import 'package:valgene_cli/types.dart';

void main() {
  test("Field.constructor with absent defaults", () {
    var f = Field(name: 'foo', type: 'integer');
    expect(f.name, equals('foo'));
    expect(f.maxLength, isNull);
    expect(f.hasMaxLength, isFalse);
  });
}
