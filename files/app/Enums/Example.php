<?php

namespace App\Enums;

use App\Services\Support\Traits\Enumerifier;

enum Example: string
{
    use Enumerifier;

    case One = 'one';
    case Two = 'two';
    case Three = 'three';

    public function translated($locale = null)
    {
        return match ($this) {
            Example::One => self::translation('One', $locale),
            Example::Two => self::translation('Two', $locale),
            Example::Three => self::translation('Three', $locale),
        };
    }
}
