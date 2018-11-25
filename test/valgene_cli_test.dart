import 'dart:io';

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

  test('that given template argument resolved directory', () {
    final cli = Cli(['--template', 'php5.5']);
    expect(cli.getTemplateFolder().existsSync(), isTrue);
  });

  test('that given invalid template dir will throw', () {
    final cli = Cli(['--template', 'fooBarBak']);
    expect(() => cli.getTemplateFolder(), throwsA(TypeMatcher<Exception>()));
  });

  test('that given template-folder argument will overrule template', () {
    final expectedDirectory = Directory.current.path;
    final cli = Cli([
      '--template', 'php5.5',
      '--template-folder', expectedDirectory
    ]);
    final templateDir = cli.getTemplateFolder();
    expect(templateDir.existsSync(), isTrue);
    expect(templateDir.path, equals(expectedDirectory));
  });

  test('that given invalid template-folder argument will throw', () {
    final cli = Cli([
      '--template', 'php5.5',
      '--template-folder', '/fooBar'
    ]);
    expect(() => cli.getTemplateFolder(), throwsA(TypeMatcher<Exception>()));
  });
}
