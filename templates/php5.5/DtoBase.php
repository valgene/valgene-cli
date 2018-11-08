<?php

{{# options.php.namespace }}
namespace {{{ _ }}}\{{ folderWithBackslash }};
{{/ options.php.namespace }}

/**
 * GENERATED CODE - DO NOT MODIFY BY HAND
 *
{{# fieldsToValidate }}
 * @property {{ field.type }} {{{ asProperty }}}
{{/ fieldsToValidate }}
 */
class DtoBase
{
    {{# fieldsToValidate }}
    const {{{ asConst }}} = '{{{ field.name }}}';
    {{/ fieldsToValidate }}

    /**
     * @param array $item
     * @return DtoBase
     */
    public static function fromArray(array $item)
    {
        $self = new static();
        {{# fieldsToValidate }}
        $self->{{{ asProperty }}} = $item[static::{{{ asConst }}}];
        {{/ fieldsToValidate }}

        return $self;
    }
}
