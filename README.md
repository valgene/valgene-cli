### Valgene CLI

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

# Given
 
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

# When

when invoking valgene  
```bash
valgene --lang php5.5 --spec petstore-expanded.yaml --option 'php.namespace:\\My\\PetStore\\Api'
```

# Then

it will generate a Validator, Dto and some Exception classes:

```bash
valgene --lang php5.5 --spec petstore-expanded.yaml --option 'php.namespace:\\My\\PetStore\\Api'
> processing petstore-expanded.yaml:
  - route [POST]    /pets
> generating validator:
  - PostPets\Valgene\ValidatorBase.php
> generating dto:
  - PostPets\Valgene\DtoBase.php
> generating exceptions:
  - PostPets\Valgene\FieldException.php
  - PostPets\Valgene\MissingFieldException.php
  - PostPets\Valgene\InvalidFieldException.php
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
     */
    public function validate($json) {
        $this->isNameValid($json, true);
        $this->isTagValid($json, false);
    }
    
    /**
     * @param array $json
     * @param bool $isRequired
     */
    protected function isNameValid($json, $isRequired) {
        // validation code is omited 
    }

    /**
     * @param array $json
     * @param bool $isRequired
     */
    protected function isTagValid($json, $isRequired) {
        // validation code is omited 
    }
}
```

Generated dto code looks like this:

..TODO..

## Installation

MacOS:
```bash
brew install valgene-cli
```

## Generating code for other languages

as seen above there is a `--lang` parameter that allows to switch the generated language/template.
```bash
valgene --lang php5.5 --spec petstore-expanded.yaml --option 'php.namespace:\\My\\PetStore\\Api'
```

In fact the code generators itself are just a couple of templates that getting rendered by the valgene engine.
The template language itself is [Mustache](https://mustache.github.io/) 
and therefore you can customize the code that is generated pretty easy.

TODO explain how in detail the a custom template can be used / provided

