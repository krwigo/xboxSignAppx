# xboxSignAppx

## Description
This collection of PowerShell scripts makes use of [OpenSSL](https://www.openssl.org/) binaries to generate keys bypassing the need to interactively input passwords when signing app packages. The [Xbox One](https://en.wikipedia.org/wiki/Xbox_Development_Kit) has a [developer mode](https://docs.microsoft.com/en-us/windows/uwp/xbox-apps/devkit-activation) where signed app packages can be [sideloaded](https://en.wikipedia.org/wiki/Sideloading) and tested.

## Dependencies
### Windows 10 SDK
* https://blogs.windows.com/buildingapps/tag/windows-10-sdk-preview-build/
* https://blogs.windows.com/buildingapps/tag/windows-10-preview-build

### OpenSSL
OpenSSL binaries can be compiled from source or downloaded from other projects. The version used during development was *openssl-1.0.2o-x64_86-win64.zip*

* https://github.com/IndySockets/OpenSSL-Binaries
* https://curl.se/windows/dl-7.75.0_5/

## Installation
1. Extract the repository files to *D:\xboxSignAppx\*
2. Run *sign_xbox.reg* to import actions to the [Windows File Explorer context menu](https://docs.microsoft.com/en-us/windows/win32/shell/context-menu-handlers). (optional)
