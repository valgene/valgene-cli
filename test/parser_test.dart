import 'dart:io';

import 'package:test/test.dart';
import 'package:valgene_cli/parser.dart';

void main() {
  final String apiDoc = '''openapi: "3.0.0"
paths:
  /pets:
    post:
      description: Creates a list of new pet in the store.  Duplicates are allowed
      operationId: addPets
      requestBody:
        description: Pets to add to the store
        required: true
        content:
          application/json:
            schema:
              \$ref: '#/components/schemas/NewPetList'
''';

  group('OpenApiLoader', () {
    test('yaml file loading to map works', () {
      final spec =
          OpenApiLoader.fromFile(File('example/petstore-expanded.yaml'));
      expect(spec['openapi'], equals('3.0.0'));
      expect(spec['paths'].keys, contains('/pets'));
      expect(spec['paths']['/pets'].keys, contains('post'));
    });

    test('yaml string loading to map works', () {
      final spec = OpenApiLoader.fromYaml(apiDoc);
      expect(spec['openapi'], equals('3.0.0'));
      expect(spec['paths'].keys, contains('/pets'));
      expect(spec['paths']['/pets'].keys, contains('post'));
    });
  });

  group('OpenApiParser', () {
    test('POST Endpoints are parsed', () {
      final spec = OpenApiLoader.fromYaml(apiDoc);
      final parser = OpenApiParser(null);

      parser.visitPostPaths(spec);
      final endpoint = parser.endpoints[0];
      expect(endpoint.endpoint, equals('PostPets'));
    });
  });
}
