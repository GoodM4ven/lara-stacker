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

    public static function random($count = 1, $asValue = false, $translated = false, $excluding = []): string|array
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
                $returns[] = $translated ? __($r['name']) : $r['name'];
            }
        }

        if (count($returns) === 1) {
            return $returns[0];
        }

        return $returns;
    }

    public static function collection($translated = false, $excluding = []): array
    {
        $cases = collect(self::cases());
        
        if (filled($excluding)) {
            foreach ($excluding as $excluded) {
                $cases = $cases->reject(fn (int $value, int $key) => $value === $excluded);
            }
        }

        return $cases
            ->map(fn ($item) => [$item['value'] => $translated ? $item->translated() : $item['name']])
            ->collapse();
    }
}
