import defaultTheme from 'tailwindcss/defaultTheme';
import colors from 'tailwindcss/colors';

import forms from '@tailwindcss/forms';
import typography from '@tailwindcss/typography';
import aspectRatio from '@tailwindcss/aspect-ratio';
import containerQueries from '@tailwindcss/container-queries';
import tailwindEasing from '@whiterussianstudio/tailwind-easing';

/** @type {import('tailwindcss').Config} */
export default {
    content: [
        './resources/views/**/*.blade.php',
        './storage/framework/views/*.php',
        './vendor/laravel/framework/src/Illuminate/Pagination/resources/views/*.blade.php',
    ],

    darkMode: 'class',

    theme: {
        extend: {
            fontFamily: {
                sans: ['Ubuntu', ...defaultTheme.fontFamily.sans],
            },
            colors: {
                gray: colors.zinc,
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
            },
            transitionProperty: {},
            keyframes: {},
            animation: {},
        },
    },

    plugins: [forms, typography, aspectRatio, containerQueries, tailwindEasing],

    variants: {
        transitionTimingFunction: ['responsive', 'hover', 'groupHover', 'focus', 'dark'],
    }
};
