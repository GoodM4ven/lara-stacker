import { defineConfig } from 'vite';
import laravel from 'laravel-vite-plugin';
// TODO Follow @defstudio/vite-livewire-plugin fix and then apply
// import livewire from "@defstudio/vite-livewire-plugin";
import path from "path";

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
            // refresh: false,
            refresh: true,
        }),
        // livewire({
        //     refresh: ["resources/css/app.css"],
        //     watch: [
        //         "resources/views/**",
        //         "app/Http/Livewire/**",
        //         "app/Filament/**",
        //         "app/Forms/Components/**",
        //         "app/Tables/Columns/**",
        //         // TODO apply conditionally
        //         "resources/lang/**",
        //         "routes/**",
        //     ],
        //     bottomPosition: 34,
        // }),
    ],
    server: {
        https: {
            cert: certPath,
            key: keyPath,
        },
        host: "<projectName>.test",
    },
});
