<?php

{{# options.php.namespace }}
namespace {{ _ }}\{{ endpoint }};
{{/ options.php.namespace }}

/**
 * GENERATED CODE - DO NOT MODIFY BY HAND
 */
class MissingFieldException extends FieldException 
{
    /**
     * @param string $field
     * @param mixed $belongsTo
     * @param string $message
     */
    public function __construct($field, $belongsTo, $message = 'payload does not contain this field')
    {
        parent::__construct($field, $belongsTo, $message);
    }
}
