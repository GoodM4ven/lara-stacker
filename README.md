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
    - [git](https://github.com/git/git)
    - [curl](https://github.com/curl/curl)
    - [ghostscript](https://ghostscript.readthedocs.io)
    - [ffmpeg](https://github.com/FFmpeg/FFmpeg)
    - [mkcert](https://github.com/FiloSottile/mkcert)
    - [php](https://www.php.net/)
    - [apache2](https://httpd.apache.org/)
    - [composer](https://getcomposer.org/)
    - [npm](https://nodejs.org/en/download/package-manager)
    - [nvm](https://github.com/nvm-sh/nvm)
    - [libnss3-tools](https://packages.ubuntu.com/focal/libnss3-tools)
    - [libgbm-dev](https://packages.debian.org/sid/libgbm-dev)
    - [libnotify-dev](https://packages.debian.org/sid/libnotify-dev)
    - [libgconf-2-4](https://packages.debian.org/unstable/libgconf-2-4)
    - [xvfb](https://packages.ubuntu.com/kinetic/xvfb)
  - Passive Services
    - [Redis](https://redis.io/) (port 6379)
    - [MySQL](https://www.mysql.com/) (port 3306)
    - [Mailpit](https://github.com/axllent/mailpit) (http://localhost:8025)
    - [MinIO](https://min.io/) (http://localhost:9000)
  - Active Services
    - [Expose](https://expose.dev/docs) (Use `expose share https://[site-name].test` to work properly)

  </p>
  </details>

- <details><summary>PHP Extensions</summary>
  <p>

  - [php-curl](https://www.php.net/manual/en/book.curl.php)
  - [php-xml](https://www.php.net/manual/en/refs.xml.php)
  - [php-dom](https://www.php.net/manual/en/book.dom.php)
  - [php-bcmath](https://www.php.net/manual/en/book.bc.php)
  - [php-imagick](https://www.php.net/manual/en/book.imagick.php)
  - [php-gd](https://www.php.net/manual/en/book.image.php)
  - [php-xdebug](https://xdebug.org/)
  - [php-zip](https://www.php.net/manual/en/book.zip.php)

  </p>
  </details>

- <details><summary>Composer</summary>
  <p>

  - Essentials
    - [league/flysystem-aws-s3-v3](https://flysystem.thephpleague.com/docs/adapter/aws-s3-v3/)
    - [laracasts/cypress](https://github.com/laracasts/cypress) [Dev]
      - Use `npx cypress open` to run the tester
      - Checkout this [episode](https://laracasts.com/series/jeffreys-larabits/episodes/22) for more details
    - [predis/predis](https://github.com/predis/predis)
    - [artesaos/seotools](https://github.com/artesaos/seotools)
    - [spatie/laravel-data](https://github.com/spatie/laravel-data)
    - [laravel/scout](https://laravel.com/docs/10.x/scout)
    - [qruto/laravel-wave](https://github.com/qruto/laravel-wave)
    - ["spatie/laravel-medialibrary:^10.0.0"](https://spatie.be/docs/laravel-medialibrary/v10)
    - [spatie/eloquent-sortable](https://github.com/spatie/eloquent-sortable)
    - [spatie/laravel-sluggable](https://github.com/spatie/laravel-sluggable)
    - [spatie/laravel-tags](https://spatie.be/docs/laravel-tags/v4)
    - [spatie/laravel-settings](https://github.com/spatie/laravel-settings)
    - [spatie/laravel-permission](https://spatie.be/docs/laravel-permission/v5)
    - [blade-ui-kit/blade-icons](https://github.com/blade-ui-kit/blade-icons)
    - [blade-ui-kit/blade-heroicons](https://github.com/blade-ui-kit/blade-heroicons)
    - [gehrisandro/tailwind-merge-laravel](https://github.com/gehrisandro/tailwind-merge-laravel)
    - [laravel/breeze](https://laravel.com/docs/10.x/starter-kits#laravel-breeze) [Dev]
    - [laravel/telescope](https://laravel.com/docs/10.x/telescope) (https://project-name.test/telescope) [Dev]
  - [Option] TALL Stack
    - [livewire/livewire](https://livewire.laravel.com/)
    - [filament/filament:"^3.0-stable"](https://filamentphp.com/docs/3.x/panels/installation) (https://project-name.test/admin)
    - [filament/forms:"^3.0-stable"](https://filamentphp.com/docs/3.x/forms/installation)
    - [filament/tables:"^3.0-stable"](https://filamentphp.com/docs/3.x/tables/installation)
    - [filament/notifications:"^3.0-stable"](https://filamentphp.com/docs/3.x/notifications/installation)
    - [filament/actions:"^3.0-stable"](https://filamentphp.com/docs/3.x/actions/installation)
    - [filament/infolists:"^3.0-stable"](https://filamentphp.com/docs/3.x/infolists/installation)
    - [filament/widgets:"^3.0-stable"](https://filamentphp.com/docs/3.x/widgets/installation)
    - [filament/spatie-laravel-media-library-plugin:"^3.0-stable"](https://filamentphp.com/plugins/filament-spatie-media-library)
    - [filament/spatie-laravel-tags-plugin:"^3.0-stable"](https://filamentphp.com/plugins/filament-spatie-tags)
    - [filament/spatie-laravel-settings-plugin:"^3.0-stable"](https://filamentphp.com/plugins/filament-spatie-settings)
    - [danharrin/livewire-rate-limiting](https://github.com/danharrin/livewire-rate-limiting)
    - [bezhansalleh/filament-shield:"^3.0@beta"](https://filamentphp.com/plugins/bezhansalleh-shield)
    - [awcodes/overlook](https://filamentphp.com/plugins/awcodes-overlook)
    - [goodm4ven/blurred-image](https://github.com/GoodM4ven/blurred-image)
  - [Option] PEST
    - [pestphp/pest](https://pestphp.com/) [Dev]
    - [pestphp/pest-plugin-faker](https://pestphp.com/docs/plugins#faker) [Dev]
    - [pestphp/pest-plugin-laravel](https://pestphp.com/docs/plugins#content-laravel) [Dev]
  - [Option] TALL Stack && PEST
    - [pestphp/pest-plugin-livewire](https://pestphp.com/docs/plugins#content-livewire) [Dev]
  - [Option] Multilingual
    - [mcamara/laravel-localization](https://github.com/mcamara/laravel-localization)
    - [spatie/laravel-translatable](https://spatie.be/docs/laravel-translatable/v6)
    - [laravel-lang/lang](https://laravel-lang.com) [Dev]
  - [Option] TALL Stack && Multilingual
    - [filament/spatie-laravel-translatable-plugin:"^3.0-stable"](https://filamentphp.com/plugins/filament-spatie-translatable)
    - [kenepa/translation-manager](https://filamentphp.com/plugins/kenepa-translation-manager)

  </p>
  </details>

- <details><summary>NPM</summary>
  <p>

  - Essentials
    - [cypress](https://www.cypress.io/)
    - [laravel-wave](https://github.com/qruto/laravel-wave)
    - [tailwindcss](https://tailwindcss.com/) [Dev]
    - [postcss](https://github.com/postcss/postcss) [Dev]
    - [autoprefixer](https://github.com/postcss/autoprefixer) [Dev]
    - [@tailwindcss/typography](https://tailwindcss.com/docs/typography-plugin) [Dev]
    - [@tailwindcss/forms](https://github.com/tailwindlabs/tailwindcss-forms) [Dev]
    - [@tailwindcss/aspect-ratio](https://github.com/tailwindlabs/tailwindcss-aspect-ratio) [Dev]
    - [@tailwindcss/container-queries](https://github.com/tailwindlabs/tailwindcss-container-queries) [Dev]
    - [tippy.js](https://atomiks.github.io/tippyjs/) [Dev]
  - [Option] TALL Stack
    - [alpinejs](https://alpinejs.dev/) (Already included in Livewire now!)
    - [@alpinejs/mask](https://alpinejs.dev/plugins/mask)
    - [@alpinejs/intersect](https://alpinejs.dev/plugins/intersect)
    - [@alpinejs/persist](https://alpinejs.dev/plugins/persist) (Already included in Livewire now!)
    - [@alpinejs/focus](https://alpinejs.dev/plugins/focus)
    - [@alpinejs/collapse](https://alpinejs.dev/plugins/collapse)
    - [@alpinejs/morph](https://alpinejs.dev/plugins/morph)
    - [@ryangjchandler/alpine-hooks](https://github.com/ryangjchandler/alpine-hooks)
    - [@ralphjsmit/alpine-animate](https://github.com/ralphjsmit/alpine-animate)
    - [@defstudio/vite-livewire-plugin](https://github.com/defstudio/vite-livewire-plugin) [Dev] (Disabled again until a fix!)
    - [alpinejs-breakpoints](https://github.com/wrsdesign/alpinejs-breakpoints) [Dev]
    - [tailwind-easing](https://github.com/wrsdesign/tailwind-easing) [Dev]

  </p>
  </details>


## Installation

- Extract the scripter somewhere and navigate into it:
  ```bash
  cd ~/Downloads && unzip ./lara-stacker-x.x.x.zip -d ./ && cd lara-stacker-x.x.x
  ```

- Create a [[.env](./.env)] file from the [[.env.example](./.env.example)] one, check its content and then fill it in; replacing the `<placeholders>`.
  ```bash
  cp .env.example .env && nano .env
  ```

- Run the script with super-user permissions:
  ```bash
  sudo chmod +x ./lara-stacker.sh && sudo ./lara-stacker.sh
  ```

- Ensure that the environment variables are all showing up in the output before selecting anything.

- Choose to [**setup**](./scripts/setup.sh) the lara stacker first, which will install everything necessary and eventually create a [[done-setup](./done-setup)] empty file in the directory.

- Then choose to [**create**](./scripts/create.sh) your first stacked project and provide it its name.

That's it. You'll have your first project accessible in the end (displaying the site's URL too). JUST be PATIENT! `:)`

> **Warning**
> I found the best way to deal with workspace settings or extensions ("recommended", they call them) is to add them to your VSC profile's extensions, but then disable them, and every time you open a new workspace (project), you enable them for the workspace only.

> **Note**
> You're free to take a look at and apply the VSC [settings](./files/.opinionated/settings.json) I'm using locally, as well as their complete [extension list](./files/.opinionated/extensions.md). (You can also set up both in their own "TALL" VSC profile or something)


## Before Production

- Reset [app/Http/Middleware/TrustedProxies.php]'s property to `protected $proxies;`


## Todos For Development:

- [ ] Allow html attribute suggestion without endless blade snippets then enable blade snippet suggestions again
- [ ] Add laravel Vue stack (VILT) with/without SSR
- [ ] Add laravel React stack (RILT) with/without SSR
- [ ] Open VSC if available (check the commented code in [scripts/create.sh])
- [ ] Run PHPUnit tests with the keybinding (ctrl+shift+r) if in PHPUnit class, and BetterPest's otherwise
- [ ] Selective installation process as a self-deleting Composer package (check [.draft/stacking-wip.md])
- [ ] Laravel Prompts


## Credits

- [TailwindCSS](https://tailwindcss.com)
- TALL Stack
  - [Alpine.js](https://alpinejs.dev)
  - [Livewire](https://livewire.laravel.com)
  - [Laravel](https://laravel.com)
  - [FilamentPHP](https://filamentphp.com)
- [Pest](https://pestphp.com)
- [Cypress](https://cypress.io)
- [Spatie](https://github.com/spatie)
- ( [Tech Stack List](#tech-stack-list) )
- ( [VSC Extensions](./files/.opinionated/extensions.md) )
- ( [Contributers](https://github.com/GoodM4ven/lara-stacker/graphs/contributors) )


## Support

Support the maintenance as well as the development of [other projects](https://github.com/sponsors/GoodM4ven) through sponsorship or one-time [donations](https://github.com/sponsors/GoodM4ven?frequency=one-time&sponsor=GoodM4ven).


## Changelogs

Please see [CHANGELOG](CHANGELOG.md) for more information on what has changed recently.


<div align="center">
   <br>والحمد لله رب العالمين
</div>
