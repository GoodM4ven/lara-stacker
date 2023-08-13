<?php

use Mcamara\LaravelLocalization\Facades\LaravelLocalization;

if (!function_exists('available_locales')) {
    function available_locales()
    {
        return array_keys(config('laravellocalization.supportedLocales'));
    }
}

if (!function_exists('current_locale')) {
    function current_locale()
    {
        return LaravelLocalization::getCurrentLocale();
    }
}

if (!function_exists('is_ar')) {
    function is_ar()
    {
        return LaravelLocalization::getCurrentLocale() === 'ar';
    }
}

if (!function_exists('current_direction')) {
    function current_direction()
    {
        return LaravelLocalization::getCurrentLocaleDirection();
    }
}

if (!function_exists('is_rtl')) {
    function is_rtl()
    {
        return current_direction() === 'rtl';
    }
}

if (!function_exists('arabify')) {
    function arabify(string $arabicText)
    {
        // ? Remove Tashkeel
        $harakat = ['ِ', 'ُ', 'ٓ', 'ٰ', 'ْ', 'ٌ', 'ٍ', 'ً', 'ّ', 'َ', 'ـ'];
        $arabicText = str_replace($harakat, '', $arabicText);

        // ? Replace Huroof
        $huroof = ['أ', 'ى', 'إ'];
        $arabicText = str_replace($huroof, 'ا', $arabicText);
        $huroof = ['ئ', 'ؤ', 'آ'];
        $arabicText = str_replace($huroof, 'ء', $arabicText);

        return $arabicText;
    }
}
