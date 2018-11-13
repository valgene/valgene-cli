import 'dart:io';

import 'package:logging/logging.dart';
import 'package:recase/recase.dart';
import 'package:valgene_cli/generator.dart';
import 'package:valgene_cli/types.dart';
import 'package:yaml/yaml.dart';

class OpenApiLoader {
  static Map fromFile(File file) {
    final String content = file.readAsStringSync();
    if (file.uri.pathSegments.last.endsWith('yaml')) {
      return fromYaml(content);
    }
    return null;
  }

  static Map fromYaml(String content) {
    return loadYaml(content);
  }
}

class OpenApiParser {
  final Logger log = Logger('OpenApiParser');
  final GeneratorContext context;
  final List<EndpointGenerator> endpoints = [];

  Map<String, Field> fields;
  Map<String, SchemaType> types;
  String currentTypeName;
  String path;
  Map root;

  OpenApiParser(this.context);

  void execute(schema) {
    visitPostPaths(schema);
    endpoints.forEach((e) => e.execute());
  }

  void visitPostPaths(schema) {
    root = schema;
    final posts = [];
    if (schema.keys.contains('paths')) {
      schema['paths'].forEach((path, def) {
        if (def.keys.contains('post')) {
          final post = Map.from(def['post'])..['path'] = path;
          posts.add(post);
          log.info('  - route [POST]    ${path}');
        }
      });
    }

    posts.forEach((post) {
      fields = {};
      types = {};
      path = post['path'];

      currentTypeName = 'requestBody';
      var payload = post[currentTypeName]['content']['application/json'];
      if (payload.keys.contains('schema')) {
        final ref = payload['schema']['\$ref'];
        final schemaRef = SchemaRef(ref, schema);
        payload = schemaRef.resolve();
        currentTypeName = schemaRef.name;
      }
      visitType(payload);
      ReCase endpoint =
          ReCase('post_' + path.replaceAll(RegExp('/\/|\{.*\}/'), '_'));

      endpoints.add(EndpointGenerator(
          context, endpoint.pascalCase, types.values.toList(growable: false)));
    });
  }

  void visitProperties(schema) {
    schema['properties']?.forEach(visitFieldTypeDefinition);
  }

  void visitItems(schema) {
    if (!schema.keys.contains('items')) {
      return;
    }
    visitRef(schema['items']);
  }

  void visitRef(schema) {
    final ref = schema['\$ref'];
    if (ref == null) {
      return;
    }
    final r = SchemaRef(ref, root);
    final type = r.resolve();
    currentTypeName = r.name;
    visitType(type);
  }

  void visitType(schema) {
    String type = schema['type'];
    if (type == null && schema['properties'] != null) {
      type = 'object';
    }
    switch (type) {
      case 'object':
        visitProperties(schema);
        visitRequired(schema);
        types[currentTypeName] =
            SchemaType(currentTypeName, fields.values.toList(growable: false));
        fields.clear();
        break;
      case 'array':
        final tmpTypes = types;
        final containerName = currentTypeName;
        visitItems(schema);
        final type = ContainerType(
            containerName, types.values.toList(growable: false).first);
        types.clear();
        types[containerName] = type;
        types.addAll(tmpTypes);
        break;
    }
  }

  void visitFieldTypeDefinition(name, typeDef) {
    fields[name] = Field(
        name: name,
        path: path,
        type: typeDef['type'],
        minLength: typeDef['minLength'],
        maxLength: typeDef['maxLength'],
        minimum: typeDef['minimum'],
        maximum: typeDef['maximum'],
        enumValues: typeDef['enum']);
  }

  void visitRequired(schema) {
    schema['required']?.forEach((name) {
      final f = fields[name];
      f.isRequired = true;
    });
  }
}

class SchemaRef {
  final String ref;
  final Map schema;
  String _name;

  SchemaRef(this.ref, this.schema);

  String get name => _name;

  Map resolve() {
    final i = ref.split('/');
    if (i.first != '#') {
      return null;
    }
    i.removeAt(0);
    Map next = schema;
    i.forEach((node) {
      _name = node;
      next = next[_name];
    });

    return next;
  }
}
