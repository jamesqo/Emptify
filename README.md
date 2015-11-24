# Emptify

A CLI script that empties the Recycle Bin. To use:

```cmd
emptify
```

## Installation

Run this from a command prompt:

```cmd
@powershell -NoProfile -ExecutionPolicy Bypass -Command "iex ((New-Object Net.WebClient).DownloadString('https://github.com/jamesqo/Emptify/raw/master/install.ps1'))"
```

## Running on Startup

By default, Emptify only runs when you tell it to. However, if you never want to look at the Recycle Bin again, run

```cmd
emptify --on-startup
```

This creates a shortcut to Emptify in your computer's Startup folder, so that every time you turn it on your bin will automatically be cleared.

## License

Emptify is licensed under the [BSD 2-clause license](bsd.license).
