import 'package:logging/logging.dart';
import 'package:recase/recase.dart';
import 'package:valgene_cli/generator.dart';

class JsonSchemaParser {
  final Logger log = Logger('JsonSchemaParser');
  final GeneratorContext context;
  final List endpoints = [];

  Map<String, Field> fields;
  String path;

  JsonSchemaParser(this.context);

  void execute(schema) {
    visitPostPaths(schema);
    endpoints.forEach((e) => e.execute());
  }

  void visitPostPaths(schema) {
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
      var payload = post['requestBody']['content']['application/json'];
      if (payload.keys.contains('schema')) {
        var ref = payload['schema']['\$ref'];
        payload = SchemaRef(ref, schema).resolve();
      }
      path = post['path'];
      visitProperties(payload);

      ReCase endpoint = ReCase('post_' + path.replaceAll('/', '_'));

      endpoints.add(EndpointGenerator(context, endpoint.pascalCase, fields.values.toList(growable: false)));
    });
  }

  void visitProperties(schema) {
    if (schema.keys.contains('properties')) {
      schema['properties'].forEach(visitFieldTypeDefinition);
    }
    if (schema.keys.contains('required')) {
      schema['required'].forEach(visitRequiredDefinition);
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

  void visitRequiredDefinition(name) {
    var f = fields[name];
    f.isRequired = true;
  }
}

class SchemaRef {
  final String ref;
  final Map schema;

  SchemaRef(this.ref, this.schema);

  Map resolve() {
    var i = ref.split('/');
    if (i.first != '#') {
      return null;
    }
    i.removeAt(0);
    Map next = schema;
    i.forEach((node) => next = next[node]);

    return next;
  }
}
