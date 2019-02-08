<?php

{{# options.php.namespace }}
namespace {{ _ }}\Exception;
{{/ options.php.namespace }}

/**
 * GENERATED CODE - DO NOT MODIFY BY HAND
 */
class FieldException extends \DomainException
{
    /** @var string */
    private $field;

    /** @var mixed */
    private $belongsTo;

    /**
     * @param string $field
     * @param mixed $belongsTo
     * @param string $message
     */
    public function __construct($field, $belongsTo, $message)
    {
        $this->field = $field;
        $this->belongsTo = $belongsTo;
        parent::__construct($message);
    }

    /**
     * @return string
     */
    public function getField()
    {
        return $this->field;
    }

    /**
     * @return mixed
     */
    public function getBelongsTo()
    {
        return $this->belongsTo;
    }
}
