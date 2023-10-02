import path from "path";
import { defineConfig } from 'vite';
import laravel from 'laravel-vite-plugin';
import livewire from '@defstudio/vite-livewire-plugin';

const host = "<projectName>.test";
const certPath = path.resolve(__dirname, "./certs/<projectName>.test.pem");
const keyPath = path.resolve(__dirname, "./certs/<projectName>.test-key.pem");

export default defineConfig({
    plugins: [
        laravel({
            input: [
                'resources/css/app.css',
                'resources/css/filament/admin/theme.css',
                'resources/js/app.js',
            ],
            refresh: false,
        }),
        livewire({
            refresh: ['resources/css/app.css'],
            watch: [
                "app/Filament/**/*.php",
                "app/Forms/**/*.php",
                "app/Infolists/**/*.php",
                "app/Livewire/**/*.php",
                "app/Providers/Filament/**/*.php",
                "app/Tables/**/*.php",
                "app/View/Components/**/*.php",
                "lang/**",
                "resources/lang/**",
                "routes/**",
            ],
        }),
    ],
    server: {
        host,
        hmr: { host },
        https: {
            cert: certPath,
            key: keyPath,
        },
    },
});
