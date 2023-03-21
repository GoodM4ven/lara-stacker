import { defineConfig } from "vite";
import path from "path";
import laravel from "laravel-vite-plugin";
import livewire from "@defstudio/vite-livewire-plugin";

const certPath = path.resolve(__dirname, "./certs/<projectName>.test.pem");
const keyPath = path.resolve(__dirname, "./certs/<projectName>.test-key.pem");

export default defineConfig({
    plugins: [
        laravel({
            input: [
                "resources/css/app.css",
                "resources/js/app.js",
                "resources/css/filament.css",
            ],
            refresh: false,
        }),
        livewire({
            refresh: ["resources/css/app.css"],
            watch: [
                "resources/views/**",
                "app/Http/Livewire/**",
                "app/Filament/**",
                "app/Forms/Components/**",
                "app/Tables/Columns/**",
                "resources/lang/**",
                "routes/**",
            ],
            bottomPosition: 34,
        }),
    ],
    server: {
        https: {
            cert: certPath,
            key: keyPath,
        },
        host: "<projectName>.test",
    },
});
