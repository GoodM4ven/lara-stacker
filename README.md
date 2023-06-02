<div align="center">
    بسم الله الرحمن الرحيم
</div>

## Introduction

Laravel Sail's [DevContainer](https://laravel.com/docs/sail#using-devcontainers) setup is great, except when it **relies on VSC and its extensions to keep up and Docker not outsmarting everybody!** Meanwhile, I'm using my Ubuntu mainly for [TALL stack](https://tallstack.dev/) development, so I might as well just do everything <u>***locally***</u>.

This way, I don't have to worry about the things I've mentioned, plus I gain the following advantages for my situation:

- Performance boost on my potatop.
- Running multiple sites at the same time and developing simultaneously, which crazy creative when it comes to simple ideas here and there!
- Customizations such as SSL and 3rd party tools setup is way easier if you deal with it locally; and doesn't necessarily mean that you'd a have a messy setup.
- Package development, when having most of the tools installed out of boxes!

### Tech Stack List

- <details><summary>System</summary>
  <p>

  - Packages
    - git
    - curl
    - ghostscript
    - ffmpeg
    - mkcert
    - php
    - apache2
    - composer
    - npm
    - nvm
    - libnss3-tools
  - Passive Services
    - Redis
    - MySQL
    - Mailpit
    - MinIO
  - Active Services
    - Expose

  </p>
  </details>

- <details><summary>PHP Extensions</summary>
  <p>

  - php-curl
  - php-xml
  - php-dom
  - php-bcmath
  - php-imagick
  - php-gd
  - php-xdebug

  </p>
  </details>

- <details><summary>Composer</summary>
  <p>

  - Global
    - phpcs (CodeSniffer)
  - Local
    - league/flysystem-aws-s3-v3
    - qruto/laravel-wave
    - predis/predis
    - laravel/scout
    - "spatie/laravel-medialibrary:^10.0.0"
    - spatie/eloquent-sortable
    - spatie/laravel-sluggable
    - mcamara/laravel-localization (multilingual option)
    - spatie/laravel-translatable (multilingual option)
    - spatie/laravel-tags
    - spatie/laravel-settings
    - spatie/laravel-options
    - blade-ui-kit/blade-icons
    - spatie/laravel-permission
    - livewire/livewire (tall stack option)
    - filament/filament:"^2.0" (tall stack option)
    - filament/forms:"^2.0" (tall stack option)
    - filament/tables:"^2.0" (tall stack option)
    - filament/notifications:"^2.0" (tall stack option)
    - filament/spatie-laravel-media-library-plugin:"^2.0" (tall stack option)
    - filament/spatie-laravel-translatable-plugin:"^2.0" (multilingual option && tall stack option)
    - filament/spatie-laravel-tags-plugin:"^2.0" (tall stack option)
    - filament/spatie-laravel-settings-plugin:"^2.0" (tall stack option)
    - danharrin/livewire-rate-limiting (tall stack option)
    - bezhansalleh/filament-shield (tall stack option)
  - Local Development
    - laravel/breeze
    - laravel/telescope
    - pestphp/pest (pest option)
    - pestphp/pest-plugin-faker (pest option)
    - pestphp/pest-plugin-laravel (pest option)
    - pestphp/pest-plugin-livewire (pest option && tall stack option)
    - laravel-lang/lang (multilingual option)

  </p>
  </details>

- <details><summary>NPM</summary>
  <p>

  - Local
    - alpinejs (tall stack option)
    - @alpinejs/mask (tall stack option)
    - @alpinejs/intersect (tall stack option)
    - @alpinejs/persist (tall stack option)
    - @alpinejs/focus (tall stack option)
    - @alpinejs/collapse (tall stack option)
    - @alpinejs/morph (tall stack option)
    - laravel-wave
  - Local Development
    - tailwindcss
    - postcss
    - autoprefixer
    - @tailwindcss/typography
    - @tailwindcss/forms
    - @tailwindcss/aspect-ratio
    - @tailwindcss/container-queries
    - tippy.js
    - @defstudio/vite-livewire-plugin [temporarily disabled] (tall stack option)
    - @awcodes/alpine-floating-ui (tall stack option)
    - alpinejs-breakpoints (tall stack option)

  </p>
  </details>


## Installation

- Extract the scripter somewhere and navigate into it:
  ```bash
  cd ~/Downloads && unzip ./tall-stacker-x.x.x.zip -d ./ && cd tall-stacker-x.x.x
  ```

- Create a [[.env](./.env)] file from the [[.env.example](./.env.example)] one, check its content and then fill it in; replacing the `<placeholders>`.
  ```bash
  cp .env.example .env && nano .env
  ```

- Run the script with super-user permissions:
  ```bash
  sudo ./tall-stacker.sh
  ```

- Ensure that the environment variables are all showing up in the output before selecting anything.

- Choose to [**setup**](./scripts/setup.sh) the tall stacker first, which will install everything necessary and eventually create a [[done-setup](./done-setup)] empty file in the directory.

- Then choose to [**create**](./scripts/create.sh) your first tall stack project and provide it its name.

That's it. You'll have your first project accessible in the end (displaying the site's URL too). JUST be PATIENT! `:)`

> **Warning**
> Please remember to install the "recommended extensions" after opening the VSC Workspace as prompted to, or "Show Recommended Extensions" from the command palette if not.

> **Note**
> You're free to take a look at and apply the VSC [settings](./files/.opinionated/settings.json) I'm using locally, as well as their complete [extension list](./files/.opinionated/extensions.md). (You can also set up both in their own "tall" VSC profile or something)


## Before Production

- Reset [app/Http/Middleware/TrustedProxies.php]'s property to `protected $proxies;`


## Todos For Development:

- [ ] Add the rest of the laravel stacks
- [ ] Link to the repos of all the packages in the stack list
- [ ] Auto-complete or suggestion mechanism while deleting the project
  - [ ] OR selection mechanism with an interface listing projects in rectangles (arrow up and down then enter)
- [ ] Open VSC if available (check the commented code in [scripts/create.sh])
- [ ] Run PHPUnit tests with the keybinding (ctrl+shift+r) if in PHPUnit class, and BetterPest's otherwise
- [ ] Selective installation process (check [.draft/stacking-wip.md])
- [ ] TheatreJS (Alpination)


## Credits

- [TailwindCSS](https://tailwindcss.com)
- [Spatie](https://github.com/spatie)
- TALL Stack
  - [Alpine.js](https://alpinejs.dev)
  - [Livewire](https://laravel-livewire.com)
  - [Laravel](https://laravel.com)
  - [FilamentPHP](https://filamentphp.com)
- ( [Tech Stack List](#tech-stack-list) )
- ( [VSC Extensions](./files/.opinionated/extensions.md) )
- ( [Workspace VSC Extensions](./files/.opinionated/project.code-workspace) )
- ( [Contributers](https://github.com/GoodM4ven/tall-stacker/graphs/contributors) )


## Support

Support the maintenance as well as the development of [other projects](https://github.com/sponsors/GoodM4ven) through sponsorship or one-time [donations](https://github.com/sponsors/GoodM4ven?frequency=one-time&sponsor=GoodM4ven).


## Changelogs

Please see [CHANGELOG](CHANGELOG.md) for more information on what has changed recently.


<div align="center">
   <br>والحمد لله رب العالمين
</div>
