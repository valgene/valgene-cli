<?php

{{# options.php.namespace }}
namespace {{ _ }}\{{ folderWithBackslash }};
{{/ options.php.namespace }}

/**
 * GENERATED CODE - DO NOT MODIFY BY HAND
 */
class MissingFieldException extends FieldException 
{
    /**
     * @param string $field
     * @param string $message
     */
    public function __construct($field, $message = 'payload does not contain this field')
    {
        parent::__construct($field, $message);
    }
}
