import 'dart:io';

import 'package:test/test.dart';
import 'package:valgene_cli/parser.dart';
import 'package:valgene_cli/types.dart';

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
components:
  schemas:
    NewPetList:
      type: array
      items:
        \$ref: '#/components/schemas/NewPet'

    NewPet:
      required:
      - name
      properties:
        name:
          type: string
        tag:
          type: string
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
      final type = endpoint.types[0];
      expect(type.name, equals('NewPetList'));
    });

    test('object with 2 array types are parsed', () {
      final String apiDoc = '''openapi: "3.0.0"
paths:
  /pets:
    post:
      requestBody:
        required: true
        content:
          application/json:
            schema:
              \$ref: '#/components/schemas/PostPetsReqest'
components:
  schemas:
    PostPetsReqest:
      type: object
      properties:
        name:
          type: string
        listOfA:
          type: array
          items:
            \$ref: '#/components/schemas/TypeA'
        listOfB:
          type: array
          items:
            \$ref: '#/components/schemas/TypeB'
    TypeA:
      properties:
        foo:
          type: string
    TypeB:
      properties:
        bar:
          type: string
''';

      final spec = OpenApiLoader.fromYaml(apiDoc);
      final parser = OpenApiParser(null);

      parser.visitPostPaths(spec);
      final endpoint = parser.endpoints[0];

      SchemaType type = endpoint.types[2];
      expect(type.name, equals('PostPetsReqest'));
      expect(type.fields[2].name, equals('name'));
      expect(type.fields[1].name, equals('listOfA'));
      expect(type.fields[1].type, equals('ListOfADto'));
      expect(type.fields[0].name, equals('listOfB'));
      expect(type.fields[0].type, equals('ListOfBDto'));

      type = endpoint.types[1];
      expect(type.name, equals('ListOfA'));
      expect((type as ContainerType).innerType.name, equals('TypeA'));
      expect((type as ContainerType).innerType.fields[0].name, equals('foo'));

      type = endpoint.types[0];
      expect(type.name, equals('ListOfB'));
      expect((type as ContainerType).innerType.name, equals('TypeB'));
      expect((type as ContainerType).innerType.fields[0].name, equals('bar'));
    });

    test('array with composed type', () {
      final String apiDoc = '''openapi: "3.0.0"
paths:
  /pets:
    post:
      requestBody:
        required: true
        content:
          application/json:
            schema:
              \$ref: '#/components/schemas/PostPetsReqest'
components:
  schemas:
    PostPetsReqest:
      type: object
      properties:
        name:
          type: string
        listOfAandB:
          type: array
          items:
            allOf:
              - \$ref: '#/components/schemas/TypeA'
              - \$ref: '#/components/schemas/TypeB'
    TypeA:
      properties:
        foo:
          type: string
    TypeB:
      properties:
        bar:
          type: string
''';

      final spec = OpenApiLoader.fromYaml(apiDoc);
      final parser = OpenApiParser(null);

      parser.visitPostPaths(spec);
      final endpoint = parser.endpoints[0];

      SchemaType type = endpoint.types[1];
      expect(type.name, equals('PostPetsReqest'));
      expect(type.fields[1].name, equals('name'));
      expect(type.fields[0].name, equals('listOfAandB'));
      expect(type.fields[0].type, equals('ListOfAandBDto'));

      type = endpoint.types[0] as ContainerType;
      expect(type.name, equals('ListOfAandB'));
      expect((type as ContainerType).innerType.name, equals('ListOfAandBItem'));
      expect((type as ContainerType).innerType.fields[0].name, equals('foo'));
      expect((type as ContainerType).innerType.fields[0].type, equals('string'));
      expect((type as ContainerType).innerType.fields[1].name, equals('bar'));
      expect((type as ContainerType).innerType.fields[1].type, equals('string'));
    });
  });
}
