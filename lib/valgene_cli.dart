import 'dart:io';

import 'package:args/args.dart';
import 'package:logging/logging.dart';

ArgParser argsParser() => new ArgParser()
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

bool isValid(ArgResults result) => result.wasParsed('spec');

void showUsage(ArgParser parser) => print(parser.usage);

Map getOptions(ArgResults args) {
  var options = [];
  if (args.wasParsed('option')) {
    options = args['option'];
  }

  Map map = {};
  options.forEach((option) {
    var keyValue = option.split(':');
    option = keyValue.first;
    var value = {'_': keyValue.last};
    _splitOption(option, value, map);
  });

  if(map['custom-folder'] == null) {
    map['custom-folder'] = 'Valgene';
  }
  return map;
}

Directory getTemplate(ArgResults args) {
  final file = File(Platform.script.toFilePath());

  return Directory(
      file.parent.parent.absolute.path + '/templates/${args['template']}');
}

void setupLogging() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((LogRecord rec) {
    print('${rec.message}');
  });
}

Map _splitOption(String key, Map value, Map options) {
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
