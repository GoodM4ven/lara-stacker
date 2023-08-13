<?php

namespace App\Enums;

use App\Services\Support\Traits\Enumerifier;

enum Example: string
{
    use Enumerifier;

    case One = 'one';
    case Two = 'two';
    case Three = 'three';

    public function translated()
    {
        return match ($this) {
            Example::One => __('One'),
            Example::Two => __('Two'),
            Example::Three => __('Three'),
        };
    }
}
