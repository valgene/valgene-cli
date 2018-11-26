<?php

{{# options.php.namespace }}
namespace {{ _ }}\{{ endpoint }};
{{/ options.php.namespace }}

/**
 * GENERATED CODE - DO NOT MODIFY BY HAND
 */
class {{ name }}DtoValidator
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
      {{# isContainer }}
        $innerValidator = new {{ itemName }}DtoValidator();
        foreach($json as $item) {
            $innerValidator->validate($item);
        }
      {{/ isContainer }}
    }
    {{# fieldsToValidate }}

    /**
     * @param array $json
     * @param bool $isRequired
     */
    protected function {{ validationMethodName }}($json, $isRequired)
    {
        $field = {{ name }}Dto::{{{ asConst }}};
        if (!array_key_exists($field, $json)) {
            if ($isRequired) {
                throw new MissingFieldException($field, $json);
            }
        {{# hasDefault }}
            $json[$field] = {{{ defaultValue }}};
        {{/ hasDefault }}
        }
        $value = $json[$field];

    {{# isNullable }}
        if ($value === null) {
            return; // nullable so that is ok
        }
    {{/ isNullable }}
    {{# isDto }}
        $v = new {{ field.type }}Validator();
        $v->validate($value);
    {{/ isDto }}
    {{# isString }}
        if (!is_string($value)) {
            throw new InvalidFieldException($field, $json, 'datatype is not string');
        }
    {{/ isString }}
    {{# isNumber }}
        if (!is_numeric($value)) {
            throw new InvalidFieldException($field, $json, 'datatype is not numeric');
        }
    {{/ isNumber }}
    {{# isBoolean }}
        if (!is_bool($value)) {
            throw new InvalidFieldException($field, $json, 'datatype is not boolean');
        }
    {{/ isBoolean }}
    {{# field.hasMinLength }}
        if (strlen($value) < {{ field.minLength }}) {
            throw new InvalidFieldException($field, $json, 'minimum length constraint violated');
        }
    {{/ field.hasMinLength }}
    {{# field.hasMaxLength }}
        if (strlen($value) > {{ field.maxLength }}) {
            throw new InvalidFieldException($field, $json, 'maximum length constraint violated');
        }
    {{/ field.hasMaxLength }}
    {{# field.hasMinimum }}
        if ($value < {{ field.minimum }}) {
            throw new InvalidFieldException($field, $json, 'minimum value constraint violated');
        }
    {{/ field.hasMinimum }}
    {{# field.hasMaximum }}
        if ($value > {{ field.maximum }}) {
            throw new InvalidFieldException($field, $json, 'maximum value constraint violated');
        }
    {{/ field.hasMaximum }}
    {{# field.hasEnumValues }}
        if (!in_array($value, {{{ enumValues }}})) {
            throw new InvalidFieldException($field, $json, 'enum constraint violated, value must be one of {{{ field.enumValues }}}.');
        }
    {{/ field.hasEnumValues }}
    }
    {{/ fieldsToValidate }}
}
