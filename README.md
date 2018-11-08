# Valgene CLI

[![Pub](https://img.shields.io/pub/v/valgene_cli.svg)](https://pub.dartlang.org/packages/valgene_cli)

## Introduction

assuming you are providing some RESTful/Web APIs, then you are familiar with the tasks of 

 - documenting the API
 - validating incoming data against the API specification
 - creating [Dtos](https://martinfowler.com/eaaCatalog/dataTransferObject.html) for dedicated API endpoints
 
Somehow these things are disconnected to each other, that means the documentation of the API is normally not used 
for validating incoming data. Neither it is used for writing a Dto class. As well all the tasks are repetitive, 
manual and error prone.

This is where Valgene kicks in and reduces a lot of pain.

## Usage

Valgene (Validation Generator) generates validator and Dto boiler plate code from 
 your [OpenAPI](https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.0.md) specs.

### Given
 
so lets assume you have an API spec [like the following](https://raw.githubusercontent.com/OAI/OpenAPI-Specification/master/examples/v3.0/petstore-expanded.yaml) 
that defines 1 endpoint that accepts incoming data, that is `[POST] /pets`.
```yaml
paths:
  /pets:
    post:
      description: Creates a new pet in the store.  Duplicates are allowed
      operationId: addPet
      requestBody:
        description: Pet to add to the store
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/NewPet'
```

The payload of the endpoint is expected to be like:
```yaml
NewPet:
  required:
    - name  
  properties:
    name:
      type: string
    tag:
      type: string    
```

### When

when invoking valgene  
```bash
valgene --template php5.5 --spec petstore-expanded.yaml --option 'php.namespace:\\My\\PetStore\\Api'
```

### Then

it will generate a Validator, Dto and some Exception classes:

```bash
valgene --template php5.5 --spec petstore-expanded.yaml --option 'php.namespace:\\My\\PetStore\\Api'
> processing petstore-expanded.yaml:
  - route [POST]    /pets
> generating:
  - PostPets/Valgene/MissingFieldException.php
  - PostPets/Valgene/DtoBase.php
  - PostPets/Valgene/FieldException.php
  - PostPets/Valgene/ValidatorBase.php
  - PostPets/Valgene/InvalidFieldException.php
```

Generated validation code looks like this:
```php
<?php

namespace \My\PetStore\Api\PostPets\Valgene;

/**
 * GENERATED CODE - DO NOT MODIFY BY HAND
 */
class ValidatorBase
{
    /**
     * @param array $json
     * @throws MissingFieldException
     * @throws InvalidFieldException
     */
    public function validate($json)
    {
        $this->isNameValid($json, true);
        $this->isTagValid($json, false);
    }

    /**
     * @param array $json
     * @param bool $isRequired
     */
    protected function isNameValid($json, $isRequired)
    {
        $field = DtoBase::PROPERTY_NAME;
        if (!isset($json[$field]) && $isRequired) {
            throw new MissingFieldException($field);
        }
        $value = $json[$field];

        if (!is_string($value)) {
            throw new InvalidFieldException($field, 'datatype is not string');
        }
    }

    /**
     * @param array $json
     * @param bool $isRequired
     */
    protected function isTagValid($json, $isRequired)
    {
        $field = DtoBase::PROPERTY_TAG;
        if (!isset($json[$field]) && $isRequired) {
            throw new MissingFieldException($field);
        }
        $value = $json[$field];

        if (!is_string($value)) {
            throw new InvalidFieldException($field, 'datatype is not string');
        }
    }
}

```

Generated dto code looks like this:

```php
<?php

namespace \My\PetStore\Api\PostPets\Valgene;

/**
 * GENERATED CODE - DO NOT MODIFY BY HAND
 *
 * @property string name
 * @property string tag
 */
class DtoBase
{
    const PROPERTY_NAME = 'name';
    const PROPERTY_TAG = 'tag';

    /**
     * @param array $item
     * @return DtoBase
     */
    public static function fromArray(array $item)
    {
        $self = new static();
        $self->name = $item[static::PROPERTY_NAME];
        $self->tag = $item[static::PROPERTY_TAG];

        return $self;
    }
}

```

## Installation

the dart way:
```bash
pub global activate valgene_cli
```

// TODO not yet done

the brew way:
```bash
brew install valgene-cli
```

// TODO not yet done

standalone:
```bash

```

## Generating code for other languages

as seen above there is a `--template` parameter that allows to switch the generated language/template.
```bash
valgene --template php5.5 --spec petstore-expanded.yaml --option 'php.namespace:\\My\\PetStore\\Api'
```

In fact the code generators itself are just a couple of templates that getting rendered by the valgene engine.
The template language itself is [Mustache](https://mustache.github.io/) 
and therefore you can customize the code that is generated pretty easy.

// TODO explain how in detail the a custom template can be used / provided

## Things to come

 - add more examples and test cases for more complex schemas
 - add support for API specs in other formats such as JSON
 - add support for a config file that lives in a own project to save the command line args
 - providing templates for other languages like Java
 - working on a IDE integration for VS Code and IntelliJ to automate things even further
 - full fledged package that can be run standalone (especially in the IDE for integration)

