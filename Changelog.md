# PSTuiTools Changelog

The change log for the PSTuiTools module.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.4.1] - 2026-02-26

### Changed

- Revised manifest to fix PowerShell host issue.

## [0.4.0] - 2026-02-26

### Added

- Added a TUI-based MP3 player, `Invoke-TuiMp3` with an alias of `tuimp3`.
- Added `Invoke-HelloWorld` to run a basic Hello World TUI.
- Added command `Invoke-PSTuiTools` to display information about module commands in a TUI. You can also launch TUIs from this interface.

### Changed

- Updated `README`.
- Updated module description in the manifest.

## [0.3.0] - 2026-02-21

### Added

- Added function `Save-TuiAssembly` to download the Terminal.Gui and Nstack .NET assemblies.
- Added TUI color demo, `Invoke-TuiColorDemo`.
- Added a TUI template script file and TUI function `Invoke-TuiTemplate` to display it.
- Added `Invoke-SystemStatus` to display system information in a TUI.

### Changed

- Updated project's `README` file.
- Updated TUI functions to not run unless in the ConsoleHost. Also added code to not run if there are platform limitations like using CimCmdlets which only works on Windows.
- Update module to attempt to better handle existing Terminal.Gui assemblies.
- Added help documentation in the `ServiceInfo` TUI.
- Moved `Get-PSTuiTools` to a separate file.
- Updated formatting for `Get-PSTuiTools`.
- Updated NStack and Terminal.Gui assemblies.
- Updated help documentation.

### Fixed

- Corrected ChangeLog layout

## [0.2.0] - 2024-07-08

### Added

- Initial release of core files and functions

[Unreleased]: https://github.com/jdhitsolutions/PSTuiTools/compare/v0.4.1..HEAD
[0.4.1]: https://github.com/jdhitsolutions/PSTuiTools/compare/v0.4.0..v0.4.1
[0.4.0]: https://github.com/jdhitsolutions/PSTuiTools/compare/v0.3.0..v0.4.0
[0.3.0]:
[0.2.0]: