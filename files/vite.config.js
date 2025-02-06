import path from "path";
import { defineConfig } from 'vite';
import laravel, { refreshPaths } from 'laravel-vite-plugin';

const host = "<projectName>.test";
const certPath = path.resolve(__dirname, "./.certs/<projectName>.test.pem");
const keyPath = path.resolve(__dirname, "./.certs/<projectName>.test-key.pem");

export default defineConfig({
    plugins: [
        laravel({
            input: [
                'resources/css/app.css',
                'resources/js/app.js',
            ],
            refresh: [
                ...refreshPaths,
            ],
        }),
    ],
    server: {
        host,
        hmr: { host },
        cors: { origin: `https://${host}` },
        https: {
            cert: certPath,
            key: keyPath,
        },
    },
});
