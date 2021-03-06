# Emptify

<img src="https://cdn.rawgit.com/jamesqo/Emptify/master/icons/icon.svg" width="30%"/>

[![AppVeyor](https://ci.appveyor.com/api/projects/status/github/jamesqo/Stall?branch=master&svg=true)](https://ci.appveyor.com/project/jamesqo/Stall)

A CLI script that empties the Recycle Bin. To use:

```cmd
emptify
```

## Installation

Run this from a command prompt:

```cmd
powershell -NoProfile -ExecutionPolicy Bypass -Command "iex (iwr 'https://github.com/jamesqo/Emptify/raw/master/install.ps1').Content" && set path=%path%;%LocalAppData%\Emptify
```

## Running on Startup

By default, Emptify only runs when you tell it to. However, if you never want to look at the Recycle Bin again, run

```cmd
emptify --on-startup
```

This creates a shortcut to Emptify in your computer's Startup folder, so that every time you turn it on your bin will automatically be cleared.

## Contributing

Contributors are welcome! Please feel free to make pull requests or report bugs to this repo.

## License

Emptify is licensed under the [BSD 2-clause license](license.bsd).
