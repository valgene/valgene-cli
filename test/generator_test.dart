import 'package:test/test.dart';
import 'package:valgene_cli/generator.dart';

void main() {
  test("File.constructor with absent defaults", () {
    var f = Field(name: 'foo');
    expect(f.name, equals('foo'));
    expect(f.maxLength, isNull);
  });
}
