import 'package:test/test.dart';
import 'package:valgene_cli/valgene_cli.dart';

void main() {
  test('that missing spec argument is not valid', () {
    final cli = Cli([]);
    expect(cli.isValid(), isFalse);
  });

  test('that given spec argument is valid', () {
    final cli = Cli(['--spec', 'somespec.yaml']);
    expect(cli.isValid(), isTrue);
  });

  test('that given spec argument is valid', () {
    final cli = Cli(['--spec', 'somespec.yaml']);
    expect(cli.isValid(), isTrue);
  });

  test('that given options are parsed', () {
    final cli = Cli(['--option', 'php.namespace:\\My\\App']);
    expect(
        cli.getOptions(),
        equals({
          'php': {
            'namespace': {'_': '\\My\\App'}
          }
        }));
  });
}
