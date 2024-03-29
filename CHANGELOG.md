# Changelog

All notable changes to `lara-stacker` will be documented in this file.

## v2.6.0 - 2023-10-19

v2.6.0

- MySQL databases management scripts
- Better option menus navigation
- Modified prompt script helper function
- Updated [./README.md]

## v2.5.0 - 2023-10-18

v2.5.0

- Added the ability to raw-create projects without a single modification
- Added SQlite installation during setup script
- Updated [./README.md]
- Added motion to be installed to front-end packages
- Fixed fonts preloading issue

## v2.4.0 - 2023-10-17

v2.4.0

- Fixed setup script supressed feedback (logging level 2)   
  
- Dropped Cypress.io in favor of Laravel Dusk   
     
  - Added Laravel Dusk to be installed during creation      
    - Added Google Chrome to be installed during setup      
    - Added a localization testing helper for Dusk      
    - Added a global Pest testing helper      
       
  
- Updated Vite's Livewire hot-reload settings yet again   
  
- Fix Xdebug log permissions   
  
- Fixed Laraphense extension settings   
  
- Updated [README.md]   
  

## v2.3.0 - 2023-10-06

v2.3.0

- Considered Bun instead of npm   
     
  - Still restored npm until everyone moves on   
  - NVM dropped down   
  - Muting bun progress is possible and done too   
  
- Fixed Livewire hot-reload in vite config file   
  
- Fixed Livewire redirection route for localized apps   
  
- Fixed cypress front-end installation   
  
- Added a remove-breeze option during creation   
  
- Hard-coded 'tall' stack for now since it's the only available   
  
- Added links to non-vsx extensions for quick access   
  
- Fixed the done-setup flag during setup script   
  
- Implemented my PR to laravel-settings spatie package   
  
- Updated [README.md]   
     
  - Written about using Breeze views and routes   
  

## v2.2.1 - 2023-10-03

v2.2.1

- Fixed the livewire updating for localized apps
- Updated opinionated VSC extensions
- Updated opinionated VSC keybindings
- Updated opinionated VSC settings

## v2.2.0 - 2023-10-02

v2.2.0

- Fixed Livewire Hot-Reload Vite plugin   
  
- Updated [README.md]   
     
  - Added a TODO to install Lunar TALL package as an option   
  
- Fixed a consistency global JS variable naming for AutoAnimate   
  
- Set Graphite to install during setup script   
  
- Removed NPM to rely solely on NVM   
  
- Updated Prettier's preferences   
  
- Updated VSC extensions list   
  
- Updated VSC keybindings   
  
- Updated VSC settings   
  

## v2.1.6 - 2023-09-24

v2.1.6

- Added AutoAnimate awesome package from FormKit   
  
- Reworked my opinionated VSC settings   
     
  - The snippets not showing in blade templates issue is gone   
  
- Restored the separate change-log Github action   
  
- Added missing migration for translation package during creation   
  
- Fixed migration indentation for translation package during creation   
  
- Commented on extensions for VSX unavailability   
     
  - Issues were issued on their repositories to remind them all!   
  
- Fixed the keybinding replacement when not using opinionated Pest   
  
- Modified the the translation-manager filament package config   
     
  - Disabled the flags display feature   
  - Hidden quick-translation page from the side-panel   
  
- Updated [README.md]   
     
  - Added a TODO for considering phpredis instead of predis by default   
  

## v2.1.5 - 2023-09-18

v2.1.5

- Combined both CLI flows into one: release then update logs

## v2.1.0 - 2023-09-18

- Made Tailwind colors available in AlpineJS   
     
  - Converted darkMode Alpine data into colorsManager   
  - Exposed defaultColors and customColors in JS   
  
- Conditioned the proxy changes to using Expose only   
  
- Added a localized fader view where it waits for fonts to be ready   
  
- Refactored the home view a bit   
  
- Added a administrator release workflow   
  
- Some minor fixes   
  

## v2.0.0 - 2023-09-11

- Rewritten everything with better and consistant prompts   
     
  - Four-space indentations   
  - Hiding setup option when already done   
  - Hiding update option when it's finished   
  - Added a prompt helper function for code-brevity   
  - Replaced copied original files with manual replacements   
  - Refactored VSC env variables into USING_VSC single one   
  - Renamed "multi-lingual" concept into "localized"   
  - Ran migrations regularily   
  
- Organized validations in place before each script   
     
  - Ensured scripts aren't being ran directly   
  - Validated against environment variables difference   
  
- Controlled message logging during the scripts   
     
  - Added a LOGGING_LEVEL env variable   
  - Set up 3 different modes for logging   
  - Hid warnings, to only show in level 2   
  - Hid regular output, to only show in level 3   
  
- Fixed dangling Apache sites upon deletion   
  
- Replaced curl with wget for the update checking process   
  
- Dropped mkcert installation command to be ran manually   
  
- Fixed Minio's service in setup script   
  
- Fixed NVM commands in setup script   
  
- Fixed Code folder permissions for the opinionated setup   
  
- Fixed the removal of non-existing VSC workspaces   
  
- Fixed Laravel Telescope migrations pubishing   
  
- Installing Expose only when its token is provided in .env   
  
- Considered [auth.json] in git-ignore   
  
- Added a JS closure in x-init   
  
- Some opinionated changes   
     
  - Updated personal settings   
  - Added a VSC extension: shellscript   
  
- Updated [README.md]   
  

## v1.3.3 - 2023-08-30

- Fixed Filament custom theming
- Fixed TailwindMerge config reference
- Renamed functions.php to language_helpers.php
- Made Cypress an NPM dev-dependency

## v1.3.2 - 2023-08-27

- Fixed missing namespace for non-multi-lingual sites!
- Better error responses
- Touched the TALL home view a bit

## v1.3.1 - 2023-08-27

Hotfix for the $USER inconsistency

## v1.3.0 - 2023-08-27

- Implemented an updating mechanism   
  
- Removed USERNAME env variable for $USER instead   
  
- Removed LARA_STACKER_DIRECTORY env variable for $PWD instead   
     
  - Allowing the script to run from any directory   
  
- Using the concept of flags for better display   
     
  - Renaming done-setup to done-setup.flag   
  

## v1.2.6 - 2023-08-27

Hotfix for RedirectLogin controller's namespace

## v1.2.5 - 2023-08-27

- Added Laravel Data package   
  
- Livewire v3 went out of Beta stage!   
     
  - No longer need to set stability "dev"   
  
- Considered "head-scripts" stack for loading once in Livewire v3   
     
  - Renamed "scripts" to "body-scripts" instead   
  
- Added an invokable controller to redirect Filament login route (TALL)   
  
- Added multi-lingual (localized) routes setup   
  
- Upgraded NPM version in setup script   
  

## v1.2.4 - 2023-08-25

- Added SEOTools package   
  
- Added Alpine Animate plugin   
     
  - Applied both reverse & remote animations in the home view   
  
- Refactored app and home tall views   
     
  - Encapsulated Alpine bindings and data   
  
- Added Filament Overlook plugin   
  
- Added Filament Translation Manager plugin for multilingual setup   
  
- Commented out Laravel Echo and Wave for manual activation when needed   
  
- Replaced Tailwind's gray with zinc color for TALL stack!   
  
- Updated the docs   
  

## v1.2.3 - 2023-08-24

- Creating an opinionated application config file during the script   
  
- Dropped manual heroicon svgs   
     
  - Defaulted svgs to its folder directly   
  
- Dropped Laravel Options package   
  
- Reworked Enumerifier without LO package   
     
  - Accounted for locale   
  - Dealing with cases mainly   
  

## v1.2.2 - 2023-08-13

Removed an extra method in HomeController

## v1.2.1 - 2023-08-13

Hotfix from a bad merge

## v1.2.0 - 2023-08-13

- Clearer outputs through out the scripts
- Moved all extensions locally, no more workspace ones
- Upgraded the setup for Livewire and Filament to v3
- Added missing keybindings
- Dropped out CodeSniffer
- Disabled Livewire Hotreload temporarily until fix
- Renamed the whole package to lara-stacker
- Added Alpine Hooks and Tippy.js
- Added TailwindCSS Merge package
- Updated Heroicons
- Added helper aliases to Ubuntu
- Fixed a project deletion bug

## v1.1.5 - 2023-06-16

- Obfuscated credentials
- Updated VSC profile settings
- Added Enumerifier helper count method
- Removed hashing for default user password
- Added `php-zip` extension
- Added alpine-hooks package to the TALL stack
- Modified VSCodium theme again
- Disabled Blade snippet completion by Laraphense

## v1.1.4 - 2023-06-11

- Conditioned opinionated changes
- Disabled Laravel Wave until module upgrade
- Fixed Better Pest extension keybinding
- Updated Heroicon manual svgs

## v1.1.3 - 2023-06-06

- Modified VSC extensions   
     
  - Commented out Alpine Intellisense until fix   
  - Added PHP Contstructor and its keybinding   
  - Added Laravel Goto Env   
  
- Moved Prettier config to a file   
  
- Disabled blade snippet suggestion   
  
- Written about using Expose   
  

## v1.1.2 - 2023-06-02

Fixed the multilingual option set

## v1.1.1 - 2023-06-02

- Making VSC workspace setup separate for each project
- Reworked the execution order and syntax
- Organized the package files
- Archived Docker testing
- Still need testing the setup script in a virtual box
- Disabled Livewire Hot-Reload temporarily
- Rewritten README.md

## v1.1.0 - 2023-05-31

- Setup a boilerplate for all the possible laravel stacks now
- Ensure that the TALL stack still works as expected
- Dropped down livewire hot-reload package for a current bug
- Finally tested the root-to-user-to-root flow during the scripts

## v1.0.8 - 2023-04-21

- Dropped Permission along Filament Shield for now
- Fixed missing SSL configuration in setup script
- Fixed MinIO's bucket permissions in create script

## v1.0.7 - 2023-04-19

- Fully tested the setup script
- Added the old changelogs
- Fixed the TelescopeServiceProvider not found bug

## v1.0.6 - 2023-04-09

- Testing the setup script with Docker (WIP)   
     
  - Silenced most of the commands   
  
- Added the missing MIT license   
  
- Added [danharrin/livewire-rate-limiting](https://github.com/danharrin/livewire-rate-limiting) to the stack   
  
- Accepting an initial argument as an option for lara-stacker script   
  
- Added a keybinding for Compare Folders package   
  
- Added automated changelogs   
  

## v1.0.5 - 2023-03-31

- Fixed the fader partial

## v1.0.4 - 2023-03-30

- Fixed MinIO's permissions issue   
     
  - Fixed bucket deletion   
  - Set livewire's temp uploads disk to 's3' as well   
  
- Fixed `login` route not defined issue (Filament related)   
  
- Added [blurred-image](https://github.com/GoodM4ven/blurred-image) package to the roster!   
  

## v1.0.3 - 2023-03-29

- Added PHP Namespace Resolver extension and keybindings   
     
  - Replaced the namespace generation shortcut with this new extension's   
  
- Fixed HTML intellisense in Blade files   
  
- Added some VSC extensions   
  
- Moved some extensions to the workspace level   
  
- Removed `headScripts` Blade stack, as it doesn't work for some reason!   
  

## v1.0.2 - 2023-03-24

- Fixed a folder name type

## v1.0.1 - 2023-03-22

- Added PHP Resolver extension settings locally (opening PHP files outside workspace folders won't throw exceptions)
- Considered [/var/www/html/.packages] folder in the VSC workspace

## v1.0.0 - 2023-03-21

- Setup packages and services
- List projects
- create a project
- delete a project
