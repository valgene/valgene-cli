import 'dart:io';

import 'package:args/args.dart';
import 'package:logging/logging.dart';
import 'package:valgene_cli/generator.dart';
import 'package:valgene_cli/parser.dart';
import 'package:valgene_cli/valgene_cli.dart' as cli;
import 'package:yaml/yaml.dart';

void main(List<String> arguments) {
  final Logger log = new Logger('main');
  final ArgParser argParser = cli.argsParser();
  final argResults = argParser.parse(arguments);

  if(!cli.isValid(argResults)) {
    cli.showUsage(argParser);
    return;
  }
  cli.setupLogging();
  final File spec = File(argResults['spec']);
  final target = new Directory(argResults['out']);
  final context = GeneratorContext(
      target,
      cli.getOptions(argResults),
      cli.getTemplate(argResults));
  final parser = new JsonSchemaParser(context);

  spec.readAsString().then((String contents) {
    final schema = loadYaml(contents);
    log.info('> processing ${spec.uri.pathSegments.last}:');
    parser.execute(schema);
  });
}
