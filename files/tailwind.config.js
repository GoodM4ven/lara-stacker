const defaultTheme = require('tailwindcss/defaultTheme');
const colors = require('tailwindcss/colors');

/** @type {import('tailwindcss').Config} */
module.exports = {
    content: [
        './vendor/laravel/framework/src/Illuminate/Pagination/resources/views/*.blade.php',
        './storage/framework/views/*.php',
        './resources/views/**/*.blade.php',
        './vendor/filament/**/*.blade.php',
    ],

    darkMode: 'class',

    theme: {
        extend: {
            fontFamily: {
                sans: ['Ubuntu', ...defaultTheme.fontFamily.sans],
                arabic: ['"Noto Sans Arabic"', ...defaultTheme.fontFamily.sans],
            },
            colors: {
                'background-1': colors.gray['50'],
                'background-2': colors.gray['100'],
                'dark-background-1': colors.gray['800'],
                'dark-background-2': colors.gray['900'],
                primary: {
                    100: '#cdf0f6',
                    200: '#9be2ee',
                    300: '#6ad3e5',
                    400: '#38c5dd',
                    500: '#06b6d4',
                    600: '#0592aa',
                    700: '#046d7f',
                    800: '#024955',
                    900: '#01242a',
                },
                'dark-primary': {
                    100: '#fcdada',
                    200: '#f9b4b4',
                    300: '#f58f8f',
                    400: '#f26969',
                    500: '#ef4444',
                    600: '#bf3636',
                    700: '#8f2929',
                    800: '#601b1b',
                    900: '#300e0e',
                },
                success: colors.green,
                warning: colors.yellow,
                danger: colors.rose,
            },
            transitionProperty: {},
            animation: {},
            keyframes: {},
        },
    },

    plugins: [
        require('@tailwindcss/typography'),
        require('@tailwindcss/forms'),
        require('@tailwindcss/aspect-ratio'),
        require('@tailwindcss/line-clamp'),
        require('@tailwindcss/container-queries'),
    ],
};
