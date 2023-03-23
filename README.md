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

### TALL Stack List

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
    - livewire/livewire
    - qruto/laravel-wave
    - predis/predis
    - mcamara/laravel-localization
    - laravel/scout
    - "spatie/laravel-medialibrary:^10.0.0"
    - filament/filament:"^2.0"
    - filament/forms:"^2.0"
    - filament/tables:"^2.0"
    - filament/notifications:"^2.0"
    - filament/spatie-laravel-media-library-plugin:"^2.0"
    - spatie/eloquent-sortable
    - spatie/laravel-sluggable
    - spatie/laravel-translatable
    - filament/spatie-laravel-translatable-plugin:"^2.0"
    - spatie/laravel-tags
    - filament/spatie-laravel-tags-plugin:"^2.0"
    - spatie/laravel-permission
    - bezhansalleh/filament-shield
    - spatie/laravel-settings
    - filament/spatie-laravel-settings-plugin:"^2.0"
    - spatie/laravel-options
    - blade-ui-kit/blade-icons
  - Local Development
    - laravel/telescope
    - pestphp/pest
    - pestphp/pest-plugin-faker
    - pestphp/pest-plugin-laravel
    - pestphp/pest-plugin-livewire
    - laravel-lang/lang

  </p>
  </details>

- <details><summary>NPM</summary>
  <p>

  - Local
    - alpinejs
    - @alpinejs/mask
    - @alpinejs/intersect
    - @alpinejs/persist
    - @alpinejs/focus
    - @alpinejs/collapse
    - @alpinejs/morph
    - laravel-wave
  - Local Development
    - tailwindcss
    - postcss
    - autoprefixer
    - @tailwindcss/typography
    - @tailwindcss/forms
    - @tailwindcss/aspect-ratio
    - @tailwindcss/line-clamp
    - @tailwindcss/container-queries
    - @defstudio/vite-livewire-plugin
    - tippy.js
    - @awcodes/alpine-floating-ui
    - alpinejs-breakpoints

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
> Please remember to install the "recommended extensions" after opening the VSC Workspace as prompted to.

> **Note**
> You're free to take a look at and apply the VSC [settings](./files/.opinionated/settings.json) I'm using locally, as well as their complete [extension list](./files/.opinionated/extensions.md). (You can also set up both in their own "tall" VSC profile or something)


## Before Production

- Reset [app/Http/Middleware/TrustedProxies.php]'s property to `protected $proxies;`


## Todos For Development:

- [ ] Quiet out the setup script and test it! 🌚
- [ ] Auto-complete or suggestion mechanism while deleting the project
  - [ ] OR selection mechanism with an interface listing projects in rectangles (arrow up and down then enter)
- [ ] Open VSC if available (check the commented code in [scripts/create.sh])
- [ ] Run PHPUnit tests with the keybinding (ctrl+shift+r) if in PHPUnit class, and BetterPest's otherwise
- [ ] Selective installation process (check [.draft/stacking-wip.md])
- [ ] Blurred Image
- [ ] TheatreJS


## Changelogs

### v1.0.2
- Fixed a folder name type

### v1.0.1
- Added PHP Resolver extension settings locally (opening PHP files outside workspace folders won't throw exceptions)
- Considered [/var/www/html/.packages] folder in the VSC workspace

### v1.0.0
- Setup packages and services
- List projects
- create a project
- delete a project


## Credits

- [TailwindCSS](https://tailwindcss.com)
- [Alpine.js](https://alpinejs.dev)
- [Livewire](https://laravel-livewire.com)
- [Laravel](https://laravel.com)
- [FilamentPHP](https://filamentphp.com)
- [Spatie](https://github.com/spatie)
- [TALL Stack List](#tall-stack-list)
- [Local VSC Extensions](./files/.opinionated/extensions.md)
- [Workspace VSC Extensions](./files/.shared/tall.code-workspace)
- [Contributers](https://github.com/GoodM4ven/tall-stacker/graphs/contributors)


## Support

Support the maintenance as well as the development of [other projects](https://github.com/sponsors/GoodM4ven).

<div align="left">
   <iframe src="https://github.com/sponsors/GoodM4ven/button" title="Sponsor GoodM4ven" height="32" width="114" style="border: 0; border-radius: 6px;"></iframe>
</div>


<div align="center">
   <br>والحمد لله رب العالمين
</div>
