document.addEventListener('alpine:init', () => {
    Alpine.data('darkMode', () => ({
        isDarkMode: false,

        toggleDarkMode() {
            document.querySelector('html').classList.toggle('dark');

            this.isDarkMode = !this.isDarkMode;
        },
    }));
});
