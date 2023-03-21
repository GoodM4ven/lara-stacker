<?php

namespace App\Services\Support\Traits;

use Spatie\LaravelOptions\Options;

trait Enumerifier
{
    public static function random($isLabel = false, $translated = false)
    {
        $random = collect(Options::forEnum(self::class))->random()[$isLabel ? 'label' : 'value'];

        return $translated ? __($random) : $random;
    }

    public static function collection()
    {
        return collect(self::cases())
            ->map(fn ($item) => [$item->value => $item->translated()])
            ->collapse();
    }

    public static function first()
    {
        return collect(Options::forEnum(self::class)->toArray())
            ->first()['value'];
    }

    public static function values($asString = false)
    {
        if ($asString) {
            return collect(self::cases())
                ->pluck('value')
                ->implode(',');
        }

        return collect(self::cases())
            ->pluck('value')
            ->toArray();
    }
}
