@props([
    'title' => null,
    'hideAppNameFromTitle' => false,
    'dir' => null,
    'bodyClasses' => null,
])

<!DOCTYPE html>
<html
    lang="{{ current_locale() }}"
    dir="{{ $dir ?? current_direction() }}"
    class="h-full min-h-screen w-full antialiased"
    x-data="{
        atMobile: false,
        atSm: false,
        atMd: false,
        atLg: false,
        atXl: false,
        at2xl: false,
    }"
    x-breakpoint="
        if ($isBreakpoint('2xl')) { at2xl = true; atXl = false; atLg = false; atMd = false; atSm = false; atMobile = false; }
        else if ($isBreakpoint('xl')) { at2xl = false; atXl = true; atLg = false; atMd = false; atSm = false; atMobile = false; }
        else if ($isBreakpoint('lg')) { at2xl = false; atXl = false; atLg = true; atMd = false; atSm = false; atMobile = false; }
        else if ($isBreakpoint('md')) { at2xl = false; atXl = false; atLg = false; atMd = true; atSm = false; atMobile = false; }
        else if ($isBreakpoint('sm')) { at2xl = false; atXl = false; atLg = false; atMd = false; atSm = true; atMobile = false; }
        else { at2xl = false; atXl = false; atLg = false; atMd = false; atSm = false; atMobile = true; }
    "
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

    {{-- <!-- Favicon -->
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
    <link
        href="https://fonts.googleapis.com/css2?family=Noto+Sans+Arabic:wght@100;200;300;400;500;600;700;800;900&display=swap"
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
</head>

<body
    @class([
        $bodyClasses => $bodyClasses,
        'font-arabic' => is_ar(),
        'h-full w-full bg-white dark:bg-dark-background-1',
    ])
    x-bind:class="{ 'overflow-y-clip': isScrollingDisabled }"
    x-data="{
        isScrollingDisabled: false,
        isDarkMode: false,
        toggleDarkMode() {
            document.querySelector('html').classList.toggle('dark');
            this.isDarkMode = !this.isDarkMode;
        },
    }"
>
    @include('partials.fader')

    {{ $slot }}

    @livewireScriptConfig
    @livewire('notifications')
    @filamentScripts
    @vite('resources/js/app.js')
    @stack('scripts')
</body>

</html>
