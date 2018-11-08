import 'dart:io';

import 'package:logging/logging.dart';
import 'package:meta/meta.dart';
import 'package:recase/recase.dart';
import 'package:mustache/mustache.dart';

import 'package:valgene_cli/utils.dart';

class Field {
  final String name;
  final String type;
  final String path;
  final int minLength;

  bool get hasMinLength => minLength != null;
  final int maxLength;

  bool get hasMaxLength => maxLength != null;
  final int minimum;

  bool get hasMinimum => minimum != null;
  final int maximum;

  bool get hasMaximum => maximum != null;
  final List enumValues;

  bool get hasEnumValues => enumValues != null;
  bool isRequired;

  Field(
      {@required String name,
      @required String type,
      int minLength: null,
      int maxLength: null,
      int minimum: null,
      int maximum: null,
      enumValues: null,
      bool isRequired = false,
      String path = '/'})
      : name = name,
        type = type,
        minLength = minLength,
        maxLength = maxLength,
        minimum = minimum,
        maximum = maximum,
        enumValues = enumValues,
        isRequired = isRequired,
        path = path;
}

abstract class FieldValidationConstraintGenerator implements StartEnd {
  void generateField(Field field);
}

class GeneratorContext {
  final Directory outputFolder;
  final Directory templateFolder;
  final Map options;

  GeneratorContext(this.outputFolder, this.options, this.templateFolder);
}

class FieldCodeArtifact {
  final Field field;
  String asConst;
  String asProperty;
  String validationMethodName;
  String validationMethodCode;
  bool isString = false;
  bool isNumber = false;
  bool isBoolean = false;

  FieldCodeArtifact(this.field) {
    ReCase rc = ReCase(field.name);
    this.asConst = 'PROPERTY_${rc.constantCase}';
    this.asProperty = rc.camelCase;
    this.validationMethodName = "is${rc.pascalCase}Valid";
    initDataType();
  }

  void initDataType() {
    switch (field.type) {
      case 'string':
        isString = true;
        break;
      case 'integer':
      case 'number':
        isNumber = true;
        break;
      case 'boolean':
        isBoolean = true;
        break;
    }
  }
}

class EndpointGenerator {
  final GeneratorContext context;
  final String endpoint;
  final List<Field> fields;
  final List codeArtifacts = List();
  final Logger log = Logger('EndpointGenerator');
  Directory outputFolder;
  String folder;
  String folderWithBackslash;

  EndpointGenerator(this.context, this.endpoint, this.fields);

  void execute() {
    folder = endpoint;
    if(context.options['custom-folder'] != null && context.options['custom-folder'].length > 0) {
      folder += '/' + context.options['custom-folder'];
    }
    folderWithBackslash = folder.replaceAll('/', '\\');
    outputFolder = Directory(context.outputFolder.path + '/' + folder);
    outputFolder.createSync(recursive: true);
    generateArtifacts();
    generateCode();
  }

  void generateCode() {
    log.info('> generating:');
    context.templateFolder
        .list(recursive: true, followLinks: false)
        .listen((FileSystemEntity entity) {
      if (entity is File) _generateFile(entity);
    });
  }

  void _generateFile(File templateFile) {
    final file = new File(outputFolder.path + '/${templateFile.uri.pathSegments.last}');
    final sink = file.openWrite();
    final source = templateFile.readAsStringSync();
    final renderContext = {
      'fieldsToValidate': codeArtifacts,
      'options': context.options,
      'folderWithBackslash': folderWithBackslash,
      'folder': folder
    };
    final template = Template(source);
    log.info('  - ${folder}/${file.uri.pathSegments.last}');
    sink.write(template.renderString(renderContext));
  }

  void generateArtifacts() {
    fields.forEach((field) => codeArtifacts.add(FieldCodeArtifact(field)));
  }
}

class FieldValidationGenerator implements FieldValidationConstraintGenerator {
  final GeneratorContext context;
  final List codeArtifacts = List();
  final Logger log = Logger('FieldValidationGenerator');

  FieldValidationGenerator(this.context);

  @override
  void generateField(Field field) {
    var f = FieldCodeArtifact(field);
    codeArtifacts.add(f);
  }

  void generateCode() {
    log.info('> generating:');
    context.templateFolder
        .list(recursive: true, followLinks: false)
        .listen((FileSystemEntity entity) {
      if (entity is File) _generateFile(entity);
    });
  }

  void _generateFile(File templateFile) {
    final file = new File(context.outputFolder.absolute.path +
        '/${templateFile.uri.pathSegments.last}');
    final sink = file.openWrite();
    final source = templateFile.readAsStringSync();
    final renderContext = {
      'fieldsToValidate': codeArtifacts,
      'options': context.options,
      'endpoint': 'Foo'
    };
    final template = Template(source);
    log.info('  - ${file.uri.pathSegments.last}');
    sink.write(template.renderString(renderContext));
  }

  @override
  void end() => generateCode();

  @override
  void start() => context.outputFolder.createSync();
}
