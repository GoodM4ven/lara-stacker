<?php

namespace App\Services\Support\Traits;

trait Enumerifier
{
    public static function count(): int
    {
        return count(self::cases());
    }

    public static function names($translated = false, $excluding = []): array
    {
        $cases = collect(self::cases());

        if (filled($excluding)) {
            foreach ($excluding as $excluded) {
                $cases = $cases->reject(fn (int $value, int $key) => $value === $excluded);
            }
        }

        if ($translated) {
            return $cases->map(fn ($item) => $item->translated())->toArray();
        }

        return $cases->pluck('name')->toArray();
    }

    public static function values($asString = false, $excluding = []): array|string
    {
        $cases = collect(self::cases());

        if (filled($excluding)) {
            foreach ($excluding as $excluded) {
                $cases = $cases->reject(fn (int $value, int $key) => $value === $excluded);
            }
        }

        $values = $cases->pluck('value');

        if ($asString) {
            return $values->implode(',');
        }

        return $values->toArray();
    }

    public static function random($count = 1, $asValue = false, $asTranslatedName = false, $excluding = []): string|array
    {
        $cases = collect(self::cases());

        if (filled($excluding)) {
            foreach ($excluding as $excluded) {
                $cases = $cases->reject(fn (int $value, int $key) => $value === $excluded);
            }
        }

        $random = $cases->random($count);
        $random = is_array($random) ? $random : [$random];
        $returns = [];

        foreach ($random as $r) {
            if ($asValue) {
                $returns[] = $r['value'];
            } else {
                $returns[] = $asTranslatedName ? __($r['name']) : $r;
            }
        }

        if (count($returns) === 1) {
            return $returns[0];
        }

        return $returns;
    }

    public static function nameValueCollection($translatedNames = false, $excluding = []): array
    {
        $cases = collect(self::cases());

        if (filled($excluding)) {
            foreach ($excluding as $excluded) {
                $cases = $cases->reject(fn (int $value, int $key) => $value === $excluded);
            }
        }

        return $cases
            ->map(function ($item) use ($translatedNames) {
                $array = [];
                $array[$item->value] = $translatedNames ? $item->translated() : $item->name;

                return $array;
            })
            ->collapse()
            ->toArray();
    }

    public static function translation(string $key, $locale = null): string
    {
        return __($key, locale: $locale);
    }
}
