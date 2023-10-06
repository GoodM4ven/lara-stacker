import tailwindColors from '../../../tailwind.config';
import colors from 'tailwindcss/colors';

document.addEventListener('alpine:init', () => {
    Alpine.data('colorsManager', () => ({
        defaultColors: colors,
        customColors: tailwindColors.theme.extend.colors,
        isDarkMode: false,

        toggleDarkMode() {
            document.querySelector('html').classList.toggle('dark');

            this.isDarkMode = !this.isDarkMode;
        },
    }));
});
