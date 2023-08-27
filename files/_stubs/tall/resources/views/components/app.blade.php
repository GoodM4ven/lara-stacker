@props([
    'title' => null,
    'hideAppNameFromTitle' => false,
    'bodyClasses' => null,
])

<!DOCTYPE html>
<html
    lang="{{ config('app.locale') }}"
    class="h-full min-h-screen w-full antialiased"
    x-bind:class="{ 'overflow-y-clip': isScrollingDisabled }"
    x-data="{
        isScrollingDisabled: false,
        atMobile: false,
        atSm: false,
        atMd: false,
        atLg: false,
        atXl: false,
        at2xl: false,
    }"
    x-bind="Breakpointer"
>

<head>
    <meta charset="utf-8">
    <meta
        name="application-name"
        content="{{ config('app.name') }}"
    >
    <meta
        name="viewport"
        content="width=device-width, initial-scale=1"
    >
    <meta
        name="csrf-token"
        content="{{ csrf_token() }}"
    >
    @stack('meta')

    {{-- <!-- Favicon | https://favicon.io/favicon-converter/ -->
    <link
        rel="apple-touch-icon"
        sizes="180x180"
        href="{{ asset('apple-touch-icon.png') }}"
    >
    <link
        rel="icon"
        type="image/png"
        sizes="32x32"
        href="{{ asset('favicon-32x32.png') }}"
    >
    <link
        rel="icon"
        type="image/png"
        sizes="16x16"
        href="{{ asset('favicon-16x16.png') }}"
    >
    <link
        rel="manifest"
        href="{{ asset('site.webmanifest') }}"
    > --}}

    <title>
        {{ filled($title) ? $title . ($hideAppNameFromTitle ? null : (' - ' . config('app.name'))) : config('app.name') }}
    </title>

    <!-- Fonts -->
    <link
        rel="preconnect"
        href="https://fonts.googleapis.com"
    >
    <link
        rel="preconnect"
        href="https://fonts.gstatic.com"
        crossorigin
    >
    <link
        href="https://fonts.googleapis.com/css2?family=Ubuntu:ital,wght@0,300;0,400;0,500;0,700;1,300;1,400;1,500;1,700&display=swap"
        rel="stylesheet"
    >
    @stack('fonts')

    <!-- Styles -->
    <style>
        [x-cloak] {
            display: none !important;
        }
    </style>
    @livewireStyles
    @filamentStyles
    @vite('resources/css/app.css')
    @stack('styles')

    <!-- Head Scripts - Load only once by default -->
    @stack('head-scripts')
</head>

<body
    @class([
        $bodyClasses => $bodyClasses,
        'h-full w-full bg-white dark:bg-dark-background-1',
    ])
    x-data="darkMode"
>
    @include('partials.fader')

    {{ $slot }}

    <!-- Body Scripts - Load on every navigation -->
    @livewireScriptConfig
    @livewire('notifications')
    @filamentScripts
    @vite('resources/js/app.js')
    @stack('body-scripts')
</body>

</html>
