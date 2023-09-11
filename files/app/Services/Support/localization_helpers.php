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
