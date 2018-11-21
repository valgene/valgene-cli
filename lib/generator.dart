import 'dart:collection';
import 'dart:io';

import 'package:logging/logging.dart';
import 'package:mustache/mustache.dart';
import 'package:recase/recase.dart';
import 'package:valgene_cli/types.dart';

class GeneratorContext {
  final Directory outputFolder;
  final Directory templateFolder;
  final Map options;

  GeneratorContext(this.outputFolder, this.options, this.templateFolder);
}

class EndpointGeneratorContext implements GeneratorContext {
  final GeneratorContext parentContext;
  final String endpoint;

  EndpointGeneratorContext(this.parentContext, this.endpoint);

  @override
  Map get options => parentContext.options;

  @override
  Directory get outputFolder => parentContext.outputFolder;

  @override
  Directory get templateFolder => parentContext.templateFolder;
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
  bool isDto = false;

  FieldCodeArtifact(this.field) {
    ReCase rc = ReCase(field.name);
    this.asConst = 'PROPERTY_${rc.constantCase}';
    this.asProperty = rc.camelCase;
    this.validationMethodName = "is${rc.pascalCase}Valid";
    initDataType();
  }

  get enumValues {
    return _toList(field.enumValues);
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
    if (field.type.endsWith('Dto')) {
      isDto = true;
    }
  }

  _toList(List values) {
    // TODO this is language specific code and should be sourced out to the a LanguageSpecificArtifact
    return IterableBase.iterableToFullString(
        values.map((v) => isString ? "\"${v}\"" : v), '[', ']');
  }
}

class EndpointGenerator {
  final GeneratorContext context;
  final String endpoint;
  final List<SchemaType> types;
  final List codeArtifacts = List();
  final Logger log = Logger('EndpointGenerator');
  Directory outputFolder;
  String folder;
  String folderWithBackslash;

  EndpointGenerator(this.context, this.endpoint, this.types);

  void execute() {
    generateOutputFolder();
    generateCode();
  }

  void generateOutputFolder() {
    folder = endpoint;
    folderWithBackslash = folder.replaceAll('/', '\\');
    outputFolder = Directory(context.outputFolder.path + '/' + folder);
    outputFolder.createSync(recursive: true);
  }

  void generateCode() {
    log.info('> generating:');
    types.forEach((type) {
      generateCodeForType(type);
    });
  }

  void generateCodeForType(SchemaType type) {
    final typeContext = EndpointGeneratorContext(context, endpoint);
    final typeGenerator = TypeGenerator(typeContext, type);
    typeGenerator.execute();
    if (type is ContainerType) {
      generateCodeForType(type.innerType);
    }
  }
}

/**
 * a TypeGenerator generates usually for a defined DataType in the API a:
 *  - Dto
 *  - DtoValidator
 */
class TypeGenerator {
  final EndpointGeneratorContext context;
  final SchemaType typeToGenerate;
  final Logger log = Logger('TypeGenerator');
  final codeArtifacts = [];
  static final generatedFiles = [];

  TypeGenerator(this.context, this.typeToGenerate);

  void execute() {
    _generateArtifacts();
    _generateFiles();
  }

  void _generateFiles() {
    context.templateFolder
        .list(recursive: true, followLinks: false)
        .listen((FileSystemEntity entity) {
      _generateFile(entity);
    });
  }

  void _generateArtifacts() {
    typeToGenerate.fields.forEach((field) {
      codeArtifacts.add(FieldCodeArtifact(field));
    });
  }

  void _generateFile(File templateFile) {
    final Map renderContext = createRenderContext();
    final String filename =
        sprintf(templateFile.uri.pathSegments.last, renderContext);
    final String relativeTargetPath = '${context.endpoint}/${filename}';
    if (generatedFiles.contains(relativeTargetPath)) {
      return;
    }

    final file = new File('${context.outputFolder.path}/${relativeTargetPath}');
    final sink = file.openWrite();
    final Template template = createTemplate(templateFile);
    renderTemplate(sink, template, renderContext);
    log.info('  - ${relativeTargetPath}');
    generatedFiles.add(relativeTargetPath);
  }

  void renderTemplate(IOSink sink, Template template, Map renderContext) =>
      sink.write(template.renderString(renderContext));

  Template createTemplate(File templateFile) {
    final source = templateFile.readAsStringSync();
    final template = Template(source);
    return template;
  }

  Map<String, Object> createRenderContext() {
    final ctx = {
      'fieldsToValidate': codeArtifacts,
      'options': context.options,
      'folderWithBackslash': context.endpoint,
      'endpoint': context.endpoint,
      'name': typeToGenerate.name,
      'isContainer': typeToGenerate is ContainerType
    };
    if (typeToGenerate is ContainerType) {
      ctx['itemName'] = (typeToGenerate as ContainerType).innerType.name;
    }
    return ctx;
  }
}

String sprintf(String str, Map variables) =>
    Template(str).renderString(variables);
