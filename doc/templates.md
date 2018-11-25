## Templates 

in templates there are some variables available that you can use to generate the code of your choice.
Below you find the list with a brief explanation what they mean. 

### options

the options that are passed form the command line. e.g. `php.namespace` where every value is wrapped inside a `_`.

To access the php namespace do like this:

```mustsache
{{# options.php.namespace }}
namespace {{{ _ }}}\{{ endpoint }};
{{/ options.php.namespace }}
```

### name

the name of the DTO in a CamelCase notation can be accessed by `{{ name }}`

### isContainer

if the DTO is a container DTO (defined as array in OpenAPI) this will be true and then an `itemName`
will be set.

### fieldsToValidate

an array of fields as the OpenAPI spec has defined it for a this a particular type. A field contains the following variables below:

 - `asConst` name of the field in CONST_CASE
 - `asProperty` name of the field in lowerCamelCase
 - `validationMethodName` name of the validationMethod that validates this field
 - `field.name` original name of the field
 - `field.type` data type of the field like `string` or `integer`
 - `field.isRequired` it is true if the field is a required field according to the OpenAPI spec
 - `field.hasMinLength` 
 - `field.minLength`
 - `field.hasMaxLength`
 - `field.maxLength`
 - `field.hasMinimum`
 - `field.minimum`
 - `field.hasMaximum`
 - `field.maximum`
 - `field.hasEnumValues`
 - `enumValues` the encoded enum values like array of strings or array of integers





