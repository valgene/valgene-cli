### Valgene CLI

## Introduction

assuming you are providing some RESTful/Web APIs, then you are familiar with the tasks of 

 - documenting the API
 - validating incoming data against the API specification
 - creating [Dtos](https://martinfowler.com/eaaCatalog/dataTransferObject.html) for dedicated API endpoints
 
Somehow these things are disconnected to each other, that means the documentation of the API is normally not used 
for validating incoming data. Neither it is used for writing a Dto class. As well all the tasks are repetitive, 
manual and error prone.

This is where Valgene kicks in and reduces a lot of pain.

## An Example

Valgene (Validation Generator) generates validator and Dto boiler plate code from 
 your [OpenAPI](https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.0.md) specs.

so lets assume you have an API spec like the following that defines 2 endpoints for listing and writing products:
```yaml


```

```bash
valgen --lang php5.5 --spec openapi.spec.yaml --option 'phpNamespace:\\My\\App\\Validator'

> processing openapi.spec.yaml:
  - route [GET]     /products
  - route [POST]    /products
> generating validator:
  - GetProductsApi\ValidatorBase.php
  - PostProductsApi\ValidatorBase.php
```

will generate a Validator like the one below:
```php
<?php

namespace \My\App\Validator\GetProductsApi;

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
        $this->isPriceValid($json, true);
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
    protected function isPriceValid($json, $isRequired) {
        // validation code is omited 
    }
}
```

## How to Install

MacOS:
```bash
brew install valgene-cli
```

## Generating code for other languages

The code generators itself are just a couple of templates that getting rendered. 
The template language itself is [Mustache](https://mustache.github.io/) and therefore you can customize the code that is generated pretty easy.

