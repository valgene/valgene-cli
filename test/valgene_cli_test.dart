import 'package:valgene_cli/valgene_cli.dart' as cli;
import 'package:test/test.dart';

void main() {
  test('That 4 command line arguments are supported', () {
    final parser = cli.argsParser();
    expect(parser.options.length, equals(4));
  });
}
