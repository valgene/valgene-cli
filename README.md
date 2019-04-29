# Valgene CLI

[![Build Status](https://travis-ci.org/valgene/valgene-cli.svg?branch=master)](https://travis-ci.org/valgene/valgene-cli#)
[![Coverage Status](https://coveralls.io/repos/github/valgene/valgene-cli/badge.svg?branch=master)](https://coveralls.io/github/valgene/valgene-cli?branch=master)
[![Pub](https://img.shields.io/pub/v/valgene_cli.svg)](https://pub.dartlang.org/packages/valgene_cli)

## Introduction

assuming you are providing some RESTful/Web APIs, then you are familiar with the tasks of

- documenting the API
- validating incoming data against the API specification
- creating [DTOs](https://martinfowler.com/eaaCatalog/dataTransferObject.html) for dedicated API endpoints

Somehow these things are disconnected to each other, that means the documentation of the API is normally not used for validating incoming data. Neither it is used for writing a DTO class. As well all the tasks are repetitive, manual and error prone.

This is where Valgene kicks in and reduces a lot of pain.

## Usage

Valgene (Validation Generator) generates validator and DTO boiler plate code from 
 your [OpenAPI](https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.0.md) specs.

### Given

so lets assume you have an API spec [like the following](https://raw.githubusercontent.com/OAI/OpenAPI-Specification/master/examples/v3.0/petstore-expanded.yaml) that defines 1 endpoint that accepts incoming data, that is `[POST] /pets`.
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
valgene --template php5.5 --spec petstore-expanded.yaml --option 'php.namespace:\My\PetStore\Api'
```

### Then

it will generate a Validator, DTO and some Exception classes:

```bash
valgene --template php5.5 --spec petstore-expanded.yaml --option 'php.namespace:\My\PetStore\Api'
> processing petstore-expanded.yaml:
  - route [POST]    /pets
> generating:
  - PostAddPet/NewPetDto.php
  - PostAddPet/NewPetDtoValidator.php
  - Exception/MissingFieldException.php
  - Exception/FieldException.php
  - Exception/InvalidFieldException.php
```

Generated Validator looks like this:
```php
<?php

namespace \My\PetStore\Api\PostAddPet;

use \My\PetStore\Api\Exception\InvalidFieldException;
use \My\PetStore\Api\Exception\MissingFieldException;

/**
 * GENERATED CODE - DO NOT MODIFY BY HAND
 */
class NewPetDtoValidator
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
        $field = NewPetDto::PROPERTY_NAME;
        if (!array_key_exists($field, $json)) {
            if ($isRequired) {
                throw new MissingFieldException($field, $json);
            }
        }
        $value = $json[$field];

        if (!is_string($value)) {
            throw new InvalidFieldException($field, $json, 'datatype is not string');
        }
    }

    /**
     * @param array $json
     * @param bool $isRequired
     */
    protected function isTagValid($json, $isRequired)
    {
        $field = NewPetDto::PROPERTY_TAG;
        if (!array_key_exists($field, $json)) {
            if ($isRequired) {
                throw new MissingFieldException($field, $json);
            }
        }
        $value = $json[$field];

        if (!is_string($value)) {
            throw new InvalidFieldException($field, $json, 'datatype is not string');
        }
    }
}
```

Generated DTO looks like this:

```php
<?php

namespace \My\Sample\Api\PostPets;

/**
 * GENERATED CODE - DO NOT MODIFY BY HAND
 */
class NewPetDto
{
    const PROPERTY_NAME = 'name';
    const PROPERTY_TAG = 'tag';

    /** @var string $name */
    public $name;

    /** @var string $tag */
    public $tag;

    /**
     * @param array $payload
     * @return NewPetDto
     */
    public static function fromArray(array $payload)
    {
        $self = new static();
        $self->name = $payload[static::PROPERTY_NAME];
        $self->tag = $payload[static::PROPERTY_TAG];

        return $self;
    }
}
```

## Customization of Templates

Be aware that the finally generated code is totally customizable and the shown example is very opinionated.
To enable your custom Templates you copy the files from the [template folder](https://github.com/valgene/valgene-cli/tree/master/templates/php5.5) to a folder on you local disk. Then you can customize them and pass the path of the folder as an argument like:

```bash
valgene --template-folder $PWD/my-custom-php-templates --spec petstore-expanded.yaml --option 'php.namespace:\My\PetStore\Api'
```

Further reading of variables available in templates you can find [here](doc/templates.md)

## Installation

[the dart way](https://www.dartlang.org/tools/pub/cmd/pub-global#activating-a-package-on-your-local-machine):
```bash
pub global activate valgene_cli
```

## Generating code for other languages

as seen above there is a `--template` parameter that allows to switch the generated language/template.
```bash
valgene --template php5.5 --spec petstore-expanded.yaml --option 'php.namespace:\My\PetStore\Api'
```

In fact the code generators itself are just a couple of templates that getting rendered by the valgene engine.
The template language itself is [Mustache](https://mustache.github.io/) and therefore you can customize the code that is generated pretty easy.

## Things to be done

- add support for API specs in other formats such as JSON
- add support for a config file that lives in a own project to save the command line args
- providing templates for other languages like Java
- working on a IDE integration for VS Code and IntelliJ to automate things even further
- full fledged package that can be run standalone (especially in the IDE for integration)