import 'dart:collection';
import 'dart:io';

import 'package:logging/logging.dart';
import 'package:recase/recase.dart';
import 'package:valgene_cli/generator.dart';
import 'package:valgene_cli/types.dart';
import 'package:yaml/yaml.dart';

class OpenApiLoader {
  static fromFile(File file) {
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
  final Queue<ContainerType> containerStack = Queue();

  Map<String, SchemaType> types;
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
      types = {};

      String currentTypeName = 'requestBody';
      var payload = post[currentTypeName]['content']['application/json'];
      if (payload.keys.contains('schema')) {
        final ref = payload['schema']['\$ref'];
        final schemaRef = SchemaRef(ref, schema);
        payload = schemaRef.resolve();
        currentTypeName = schemaRef.name;
      }
      types[currentTypeName] = visitType(payload, currentTypeName);

      endpoints.add(EndpointGenerator(
          context, endpointName(post), types.values.toList(growable: false)));
    });
  }

  String endpointName(Map post) {
    path = post['path'];
    final operationId = post['operationId'];
    if (operationId != null) {
      path = operationId;
    }
    path = path.replaceAll(RegExp('/\/|\{.*\}/'), '_');
    ReCase endpoint = ReCase('post_' + path);
    return endpoint.pascalCase;
  }

  void visitProperties(schema, SchemaType type) {
    schema['properties']?.forEach((name, value) {
      type.fields.add(visitFieldTypeDefinition(value, name));
    });
  }

  void visitItems(schema, ContainerType container) {
    if (!schema.keys.contains('items')) {
      return;
    }
    var items = schema['items'];
    if (items.keys.contains('\$ref')) {
      container.innerType = visitRef(items);
    } else if (items.keys.contains('allOf')) {
      SchemaType type = null;
      items['allOf'].forEach((value) {
        if (type == null) {
          type = visitRef(value);
        } else {
          var t = visitRef(value);
          if (t == null) {
            throw Exception("Something went wrong: ${value}.");
          }
          type.fields.addAll(t.fields);
        }
      });
      container.innerType = SchemaType(container.name + 'Item')
        ..fields.addAll(type.fields);
    }
  }

  SchemaType visitRef(schema) {
    final ref = schema['\$ref'];
    if (ref == null) {
      return null;
    }
    final r = SchemaRef(ref, root);
    final type = r.resolve();
    return visitType(type, r.name);
  }

  SchemaType visitType(schema, String currentTypeName) {
    String type = schema['type'];
    if (type == null && schema['properties'] != null) {
      type = 'object';
    }
    switch (type) {
      case 'object':
        return visitTypeObject(schema, currentTypeName);
        break;
      case 'array':
        return visitTypeArray(schema, currentTypeName);
        break;
    }
    return null;
  }

  SchemaType visitTypeArray(schema, String currentTypeName) {
    final container = _newContainerType(currentTypeName);
    visitItems(schema, container);
    if (container.innerType == null) {
      throw Exception('ContainerType did not wrap an inner type. ${schema}');
    }
    return container;
  }

  SchemaType visitTypeObject(schema, String currentTypeName) {
    final type = SchemaType(currentTypeName);
    visitProperties(schema, type);
    visitRequired(schema, type);
    return type;
  }

  Field visitFieldTypeDefinition(typeDef, name) {
    var typeName = typeDef['type'];
    final type = visitType(typeDef, name);
    if (type != null) {
      _addType(type);
      typeName = type.name + 'Dto';
    }

    final field = Field(
        name: name,
        format: typeDef['format'],
        path: path,
        type: typeName,
        minLength: typeDef['minLength'],
        maxLength: typeDef['maxLength'],
        minimum: typeDef['minimum'],
        maximum: typeDef['maximum'],
        enumValues: typeDef['enum'],
        defaultValue: typeDef['default']);

    return field;
  }

  void visitRequired(schema, SchemaType type) {
    schema['required']?.forEach((name) {
      type.getField(name)?.isRequired = true;
    });
  }

  void _addType(SchemaType type) {
    types[type.key] = type;
  }

  ContainerType _newContainerType(String currentTypeName) {
    final containerType = ContainerType(currentTypeName, null);
    containerStack.addLast(containerType);
    return containerType;
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
