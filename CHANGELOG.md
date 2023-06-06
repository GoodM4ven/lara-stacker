# Changelog

All notable changes to `tall-stacker` will be documented in this file.

## v1.1.3 - 2023-06-06

- Modified VSC extensions
- - Commented out Alpine Intellisense until fix
- - Added PHP Contstructor and its keybinding
- - Added Laravel Goto Env
- 
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
- - Silenced most of the commands
- 
- 
- 
- 
- 
- 
- Added the missing MIT license
- Added [danharrin/livewire-rate-limiting](https://github.com/danharrin/livewire-rate-limiting) to the stack
- Accepting an initial argument as an option for tall-stacker script
- Added a keybinding for Compare Folders package
- Added automated changelogs

## v1.0.5 - 2023-03-31

- Fixed the fader partial

## v1.0.4 - 2023-03-30

- Fixed MinIO's permissions issue
- - Fixed bucket deletion
- 
- 
- 
- 
- 
- - Set livewire's temp uploads disk to 's3' as well
- 
- 
- 
- 
- 
- 
- Fixed `login` route not defined issue (Filament related)
- Added [blurred-image](https://github.com/GoodM4ven/blurred-image) package to the roster!

## v1.0.3 - 2023-03-29

- Added PHP Namespace Resolver extension and keybindings
- - Replaced the namespace generation shortcut with this new extension's
- 
- 
- 
- 
- 
- 
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
