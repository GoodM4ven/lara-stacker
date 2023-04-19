# Changelog

All notable changes to `tall-stacker` will be documented in this file.

## v1.0.6 - 2023-04-09

- Testing the setup script with Docker (WIP)
  - Silenced most of the commands
- Added the missing MIT license
- Added [danharrin/livewire-rate-limiting](https://github.com/danharrin/livewire-rate-limiting) to the stack
- Accepting an initial argument as an option for tall-stacker script
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
