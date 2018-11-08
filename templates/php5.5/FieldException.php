<?php

{{# options.php.namespace }}
namespace {{ _ }}\{{ folderWithBackslash }};
{{/ options.php.namespace }}

/**
 * GENERATED CODE - DO NOT MODIFY BY HAND
 */
class FieldException extends \DomainException
{
    /** @var string */
    private $field;

    /**
     * @param string $field
     * @param string $message
     */
    public function __construct($field, $message)
    {
        $this->field = $field;
        parent::__construct($message);
    }

    /**
     * @return string
     */
    public function getField()
    {
        return $this->field;
    }
}
