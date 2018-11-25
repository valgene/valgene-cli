import 'dart:io';

import 'package:args/args.dart';
import 'package:logging/logging.dart';
import 'package:valgene_cli/generator.dart';
import 'package:valgene_cli/parser.dart';
import 'package:yaml/yaml.dart';

class Cli {
  static const argTemplate = 'template';
  static const argTemplateFolder = 'template-folder';
  static const argOption = 'option';
  static const argSpecFile = 'spec';
  static const argOutputFolder = 'out';

  final Logger log = Logger('Cli');
  final ArgParser argParser = new ArgParser()
    ..addOption(argSpecFile,
        help: 'OpenAPI specification file .yaml', valueHelp: 'file')
    ..addOption(argTemplate,
        defaultsTo: 'php5.5', help: 'code template folder for code generation')
    ..addOption(argTemplateFolder,
        help:
            'code template folder local path. Note that this option will overwrite ${argTemplate} option',
        valueHelp: 'directory')
    ..addOption(argOutputFolder,
        abbr: 'o',
        defaultsTo: 'out',
        help: 'target folder for the generated code',
        valueHelp: 'directory')
    ..addMultiOption(argOption,
        help: 'add template specific options. multiple are allowed',
        valueHelp: 'scope.subcope:value');

  final Iterable<String> arguments;
  ArgResults parsedArguments;

  Cli(this.arguments) {
    parsedArguments = argParser.parse(arguments);
    _setupLogging();
  }

  bool isValid() {
    return parsedArguments.wasParsed(argSpecFile);
  }

  void showUsage() => print(argParser.usage);

  void execute() {
    final File spec = File(parsedArguments[argSpecFile]);
    final target = Directory(parsedArguments[argOutputFolder]);
    final context = GeneratorContext(target, getOptions(), getTemplateFolder());
    final parser = OpenApiParser(context);

    spec.readAsString().then((String contents) {
      final schema = loadYaml(contents);
      log.info('> processing ${spec.uri.pathSegments.last}:');
      parser.execute(schema);
    });
  }

  Directory getTemplateFolder() {
    Directory dir;
    if (parsedArguments.wasParsed(argTemplateFolder)) {
      dir = Directory(parsedArguments[argTemplateFolder]);
    } else {
      dir = _getTemplateFolderByTemplateArg();
    }
    if (!dir.existsSync()) {
      throw Exception('Template directory does not exist: ${dir.toString()}');
    }
    return dir;
  }

  Directory _getTemplateFolderByTemplateArg() {
    var root = '';
    if (Platform.script.scheme == 'data') {
      root = Directory.current.path;
    } else {
      root = File(Platform.script.path).parent.parent.absolute.path;
    }

    final dir = Directory('${root}/templates/${parsedArguments[argTemplate]}');
    return dir;
  }

  Map getOptions() {
    var options = [];
    if (parsedArguments.wasParsed(argOption)) {
      options = parsedArguments[argOption];
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

  void _setupLogging() {
    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((LogRecord rec) {
      print('${rec.message}');
    });
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
