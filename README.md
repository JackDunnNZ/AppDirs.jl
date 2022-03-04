# AppDirs

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://JackDunnNZ.github.io/AppDirs.jl/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://JackDunnNZ.github.io/AppDirs.jl/dev)
[![Build Status](https://github.com/JackDunnNZ/AppDirs.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/JackDunnNZ/AppDirs.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/JackDunnNZ/AppDirs.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/JackDunnNZ/AppDirs.jl)

AppDirs.jl is a port of
[appdirs](https://github.com/ActiveState/appdirs) to Julia. It lets you find
the appropriate directory to save caches, logs, and data, on Linux, Mac,
and Windows.

## Motivation

What directory should your app use for storing user data? If running on
Mac OS X, you should use:

    ~/Library/Application Support/<AppName>

If on Windows (at least English Win XP) that should be:

    C:\Documents and Settings\<User>\Application Data\Local Settings\<AppAuthor>\<AppName>

or possibly:

    C:\Documents and Settings\<User>\Application Data\<AppAuthor>\<AppName>

for [roaming
profiles](https://docs.microsoft.com/en-us/previous-versions/windows/it-pro/windows-vista/cc766489(v=ws.10))
but that is another story.

On Linux (and other Unices) the dir, according to the [XDG
spec](https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html)
(and subject to some interpretation), is either:

    ~/.config/<AppName>

or possibly:

    ~/.local/share/<AppName>

## Usage

This kind of thing is what AppDirs.jl is for. AppDirs.jl will help you
choose an appropriate:

-   user data dir (`user_data_dir`)
-   site data dir (`site_data_dir`)
-   user config dir (`user_config_dir`)
-   site config dir (`site_config_dir`)
-   user cache dir (`user_cache_dir`)
-   user state dir (`user_state_dir`)
-   user log dir (`user_log_dir`)

For example, on Mac:

```julia-repl
julia> using AppDirs

julia> appname = "SuperApp"

julia> appauthor = "Acme"

julia> user_data_dir(appname, appauthor)
"/Users/username/Library/Application Support/SuperApp"

julia> site_data_dir(appname, appauthor)
#> [1] "/Library/Application Support/SuperApp"

julia> user_config_dir(appname, appauthor)
"/Users/username/Library/Preferences/SuperApp"

julia> site_config_dir(appname, appauthor)
"/Library/Preferences/SuperApp"

julia> user_cache_dir(appname, appauthor)
"/Users/username/Library/Caches/SuperApp"

julia> user_state_dir(appname, appauthor)
"/Users/username/Library/Application Support/SuperApp"

julia> user_log_dir(appname, appauthor)
"/Users/username/Library/Logs/SuperApp"
```
