<?php

{{# options.php.namespace }}
namespace {{ _ }}\{{ folderWithBackslash }};
{{/ options.php.namespace }}

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
      {{# fieldsToValidate }}
        $this->{{ validationMethodName }}($json, {{{ field.isRequired }}});
      {{/ fieldsToValidate }}
    }
    {{# fieldsToValidate }}

    /**
     * @param array $json
     * @param bool $isRequired
     */
    protected function {{ validationMethodName }}($json, $isRequired)
    {
        $field = DtoBase::{{{ asConst }}};
        if (!isset($json[$field]) && $isRequired) {
            throw new MissingFieldException($field);
        }
        $value = $json[$field];

    {{# isString }}
        if (!is_string($value)) {
            throw new InvalidFieldException($field, 'datatype is not string');
        }
    {{/ isString }}
    {{# isNumber }}
        if (!is_numeric($value)) {
            throw new InvalidFieldException($field, 'datatype is not numeric');
        }
    {{/ isNumber }}
    {{# isBoolean }}
        if (!is_bool($value)) {
            throw new InvalidFieldException($field, 'datatype is not boolean');
        }
    {{/ isBoolean }}
    {{# field.hasMinLength }}
        if (strlen($value) < {{ field.minLength }}) {
            throw new InvalidFieldException($field, 'minimum length constraint violated');
        }
    {{/ field.hasMinLength }}
    {{# field.hasMaxLength }}
        if (strlen($value) > {{ field.maxLength }}) {
            throw new InvalidFieldException($field, 'maximum length constraint violated');
        }
    {{/ field.hasMaxLength }}
    {{# field.hasMinimum }}
        if ($value < {{ field.minimum }}) {
            throw new InvalidFieldException($field, 'minimum value constraint violated');
        }
    {{/ field.hasMinimum }}
    {{# field.hasMaximum }}
        if ($value > {{ field.maximum }}) {
            throw new InvalidFieldException($field, 'maximum value constraint violated');
        }
    {{/ field.hasMaximum }}
    {{# field.hasEnumValues }}
        if (!in_array($value, {{{ field.enumValues }}})) {
            throw new InvalidFieldException($field, 'enum constraint violated');
        }
    {{/ field.hasEnumValues }}
    }
    {{/ fieldsToValidate }}
}
