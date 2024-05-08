<div align="center">
    بسم الله الرحمن الرحيم
</div>


## Introduction

Laravel Sail's [DevContainer](https://laravel.com/docs/sail#using-devcontainers) setup is great, except when it **relies on VSC and some weird extensions to keep up with; let alone Docker not outsmarting everybody!** Meanwhile, I might as well just do my [TALL stack](https://tallstack.dev/) development <u>***locally***</u>.

With this setup, I don't have to worry about the things I've mentioned, plus I gain the following advantages too:

- Performance boost on potatops.
- Running multiple sites at the same time and developing simultaneously, which is crazy creative when it comes to simple ideas here and there!
- Customizations such as SSL and 3rd party tools integration is way easier if you deal with it locally; and doesn't necessarily mean that you'd have a messy setup if every step is documented or sectioned through organized scripts; I hope.
- Packages, and native apps development soon enough, are just natural when having most of the tools installed out of boxes!

### Tech Stack List

- Packages
  - [git](https://github.com/git/git)
  - [curl](https://github.com/curl/curl)
  - **[php](https://www.php.net/)**
  - **[apache2](https://httpd.apache.org/)**
  - [sqlite3](https://www.sqlite.org/index.html)
  - **[npm](https://www.npmjs.com/)**
  - [ghostscript](https://ghostscript.readthedocs.io)
  - [ffmpeg](https://github.com/FFmpeg/FFmpeg)
  - [google-chrome-stable](https://www.google.com/chrome/)
  - **[bun](https://bun.sh)**
  - **[composer](https://getcomposer.org/)**
  - [mkcert](https://github.com/FiloSottile/mkcert)
  - [libnss3-tools](https://packages.ubuntu.com/focal/libnss3-tools)

- PHP Extensions
  - [php-curl](https://www.php.net/manual/en/book.curl.php)
  - [php-xml](https://www.php.net/manual/en/refs.xml.php)
  - [php-dom](https://www.php.net/manual/en/book.dom.php)
  - [php-bcmath](https://www.php.net/manual/en/book.bc.php)
  - [php-zip](https://www.php.net/manual/en/book.zip.php)
  - [php-imagick](https://www.php.net/manual/en/book.imagick.php)
  - [php-gd](https://www.php.net/manual/en/book.image.php)
  - [php-xdebug](https://xdebug.org/)
  - [php-mysql](https://www.php.net/manual/en/book.mysql.php)

- Bun Packages
  - [@withgraphite/graphite-cli@stable](https://graphite.dev/)

- Passive Services
  - [redis-server](https://redis.io/) (port 6379)
  - [mysql-server](https://www.mysql.com/) (port 3306)
  - [mailpit](https://github.com/axllent/mailpit) (http://localhost:8025)
  - [minio](https://min.io/) (http://localhost:9000)

- Active Services
  - [expose](https://expose.dev/docs) (Installed if `EXPOSE_TOKEN` is provided in [.env] file. Use `expose share https://[site-name].test` to work properly)


## Installation

- Extract the scripter somewhere and navigate into it:
  ```bash
  cd ~/Downloads && unzip ./lara-stacker-x.x.x.zip -d ./ && cd lara-stacker-x.x.x
  ```

- Create a [[.env](./.env)] file from the [[.env.example](./.env.example)] one and fill in its content; replacing the `<placeholders>`.
  ```bash
  cp .env.example .env && nano .env
  ```

- Run the script with super-user permissions:
  ```bash
  chmod +x ./lara-stacker.sh && sudo ./lara-stacker.sh
  ```

- Choose to [**setup**](./scripts/setup.sh) your Ubuntu environment first, which will install everything necessary for local PHP development, and eventually create a [done-setup.flag] file in the directory.

- Then choose to either:
  - Create a [**TALL**](./scripts/TALL/create.sh) project through its management section, then continue onwards with the installed [TALL-Stacker](https://github.com/GoodM4ven/tall-stacker) package via its Artisan command.
  - Or just create a [**raw**](./scripts/create_raw.sh) Laravel one, instead.
  - You can also [**import**](./scripts/TALL/import.sh) an already existing project into the same setup.

That's it. You'll have your first project accessible in the end (displaying the site's URL too). And just praise Allah instead of wasting the waiting time! `:)`

> [!NOTE]
> If you want to debug the process or display all output during the scripts, change the `LOGGING_LEVEL` variable in your [[.env](./.env)] file.


## Before Production

- If you'd provided an Expose token, reset [app/Http/Middleware/TrustedProxies.php]'s property to `protected $proxies;`.


## Todos For Development:

- [ ] Open VSC (or [Codium](https://vscodium.com/)) if available
- [ ] Consider `phpredis` extension instead of `predis` for both setup and creation scripts
- [ ] Find a consistant fix for `$USERNAME` env-variable
- [ ] Automate the `mkcert` installation command during setup script without password
- [ ] Turn the main skeleton scripter into a NativePHP app or hard-code a specific `PHP_VERSION` maybe


## Credits

- ( [Tech Stack List](#tech-stack-list) )

- ( [VSC Extensions](./files/.opinionated/extensions.md) )
  > [!TIP]
  > The best way to deal with workspace settings or extensions is to separate them into their own "TALL" or "Laravel" VSC Profile.

  > [!NOTE]
  > Feel free to take a look at my VSC [settings](./.opinionated/settings.json), [keybindings](./.opinionated/keybindings.json), and their complete [extension list](./.opinionated/extensions.md) as well.

- ( [Contributers](https://github.com/GoodM4ven/lara-stacker/graphs/contributors) )


## Support

Support the maintenance as well as the development of [other projects](https://github.com/sponsors/GoodM4ven) through sponsorship or one-time [donations](https://github.com/sponsors/GoodM4ven?frequency=one-time&sponsor=GoodM4ven).


## Changelogs

Please see [CHANGELOG](CHANGELOG.md) for more information on what has changed recently.


<div align="center">
   <br>والحمد لله رب العالمين
</div>
