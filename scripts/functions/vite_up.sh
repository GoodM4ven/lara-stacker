viteUp() {
    # ? Take in the arguments
    local escaped_project_name="$1"

    local projects_directory="/var/www/html"
    local vite_config_file="vite.config.js"

    cd $projects_directory/$escaped_project_name

    # ? Link the project's url to Vite configuration file
    pattern="const host = \"${escaped_project_name}.test\";"
    if ! grep -qF -- "$pattern" "$vite_config_file"; then
        sed -i '/import { defineConfig } from '"'"'vite'"'"';/i import path from "path";' $vite_config_file
        sed -i "/import laravel from 'laravel-vite-plugin';/a \\
\\
const host = \"${escaped_project_name}.test\";\\
const certPath = path.resolve(__dirname, \`./certs/\${host}.pem\`);\\
const keyPath = path.resolve(__dirname, \`./certs/\${host}-key.pem\`);" $vite_config_file
        sed -i '/^});/i \    server: {\
            host,\
            hmr: { host },\
            https: {\
                cert: certPath,\
                key: keyPath,\
            },\
        },' $vite_config_file

        sudo $lara_stacker_dir/scripts/helpers/permit.sh ./$vite_config_file

        echo -e "\nLinked the site URL in the project's Vite configuration file." >&3
    fi
}
