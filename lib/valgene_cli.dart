import 'dart:io';

import 'package:args/args.dart';
import 'package:logging/logging.dart';
import 'package:valgene_cli/generator.dart';
import 'package:valgene_cli/parser.dart';
import 'package:yaml/yaml.dart';

class Cli {
  final Logger log = Logger('Cli');
  final ArgParser argParser = new ArgParser()
    ..addOption('spec',
        help: 'OpenAPI specification file .yaml', valueHelp: 'file')
    ..addOption('template',
        defaultsTo: 'php5.5', help: 'code template folder for code generation')
    ..addOption('out',
        abbr: 'o',
        defaultsTo: 'out',
        help: 'target folder for the generated code',
        valueHelp: 'directory')
    ..addMultiOption('option',
        help: 'add template specific options. multiple are allowed',
        valueHelp: 'scope.subcope:value');

  final Iterable<String> arguments;
  ArgResults parsedArguments;

  Cli(this.arguments) {
    parsedArguments = argParser.parse(arguments);
    _setupLogging();
  }

  bool isValid() {
    return parsedArguments.wasParsed('spec');
  }

  void showUsage() => print(argParser.usage);

  void execute() {
    final File spec = File(parsedArguments['spec']);
    final target = Directory(parsedArguments['out']);
    final context = GeneratorContext(target, _getOptions(), _getTemplate());
    final parser = OpenApiParser(context);

    spec.readAsString().then((String contents) {
      final schema = loadYaml(contents);
      log.info('> processing ${spec.uri.pathSegments.last}:');
      parser.execute(schema);
    });
  }

  void _setupLogging() {
    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((LogRecord rec) {
      print('${rec.message}');
    });
  }

  Directory _getTemplate() {
    if (Platform.script.scheme == 'data') {
      throw Exception('unable to determine the template folder');
    }
    final file = File(Platform.script.toFilePath());

    return Directory(file.parent.parent.absolute.path +
        '/templates/${parsedArguments['template']}');
  }

  Map _getOptions() {
    var options = [];
    if (parsedArguments.wasParsed('option')) {
      options = parsedArguments['option'];
    }

    Map map = {};
    options.forEach((option) {
      var keyValue = option.split(':');
      option = keyValue.first;
      var value = {'_': keyValue.last};
      _splitOption(option, value, map);
    });

    return map;
  }

  static Map _splitOption(String key, Map value, Map options) {
    var scopes = key.split('.');
    var next = options;
    scopes.forEach((scope) {
      if (!next.containsKey(scope)) {
        next[scope] = {};
      }
      next = next[scope];
    });
    next.addAll(value);

    return options;
  }
}
