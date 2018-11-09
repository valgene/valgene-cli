<?php

{{# options.php.namespace }}
namespace {{{ _ }}}\{{ endpoint }};
{{/ options.php.namespace }}

/**
 * GENERATED CODE - DO NOT MODIFY BY HAND
 */
class {{ name }}Dto
{
{{^ isContainer }}
  {{# fieldsToValidate }}
    const {{{ asConst }}} = '{{{ field.name }}}';
  {{/ fieldsToValidate }}
  {{# fieldsToValidate }}

    /** @var {{ field.type }} ${{{ asProperty }}} */
    public ${{{ asProperty }}};
  {{/ fieldsToValidate }}
{{/ isContainer }}
{{# isContainer }}
    /**
     * @var {{ itemName }}Dto[]
     */
    public $items = [];
{{/ isContainer }}

    /**
     * @param array $payload
     * @return {{ name }}Dto
     */
    public static function fromArray(array $payload)
    {
        $self = new static();
    {{# isContainer }}
        foreach ($payload as $item) {
            $self->items[] = {{ itemName }}Dto::fromArray($item);
        }
    {{/ isContainer }}
    {{^ isContainer }}
      {{# fieldsToValidate }}
        $self->{{{ asProperty }}} = $payload[static::{{{ asConst }}}];
      {{/ fieldsToValidate }}
    {{/ isContainer }}

        return $self;
    }
}
