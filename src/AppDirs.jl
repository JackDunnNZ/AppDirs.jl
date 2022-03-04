module AppDirs

export user_data_dir, site_data_dir,
       user_config_dir, site_config_dir,
       user_cache_dir, user_state_dir, user_log_dir

@doc raw"""
    user_data_dir(appname=nothing, appauthor=nothing, version=nothing,
                  roaming::Bool=false)

Return full path to the user-specific data dir for this application.

- `appname` is the name of application. If `nothing`, just the system directory
  is returned.

- `appauthor` (only used on Windows) is the name of the
  appauthor or distributing body for this application. Typically
  it is the owning company name. This falls back to `appname`. You may
  pass `false` to disable it.

- `version` is an optional version path element to append to the path. You
  might want to use this if you want multiple versions of your app to be able
  to run independently. If used, this would typically be `"<major>.<minor>"`.
  Only applied when `appname` is present.

- `roaming` (default `false`) can be set `true` to use the Windows roaming
  appdata directory. That means that for users on a Windows network setup for
  roaming profiles, this user data will be sync'd on login. See
  [here](http://technet.microsoft.com/en-us/library/cc766489(WS.10).aspx)
  for a discussion of issues.

Typical user data directories are:

| Setting              | Path                                                                                         |
|:---------------------|:---------------------------------------------------------------------------------------------|
| macOS                | `~/Library/Application Support/<AppName>`                                                    |
| Unix                 | `~/.local/share/<AppName>` (or in `XDG_DATA_HOME`, if defined)                               |
| Win XP (not roaming) | `C:\Documents and Settings\<username>\Application Data\<AppAuthor>\<AppName>`                |
| Win XP (roaming)     | `C:\Documents and Settings\<username>\Local Settings\Application Data\<AppAuthor>\<AppName>` |
| Win 7  (not roaming) | `C:\Users\<username>\AppData\Local\<AppAuthor>\<AppName>`                                    |
| Win 7  (roaming)     | `C:\Users\<username>\AppData\Roaming\<AppAuthor>\<AppName>`                                  |
"""
function user_data_dir(appname=nothing, appauthor=nothing; version=nothing,
                       roaming::Bool=false)
  if Sys.iswindows()
    if isnothing(appauthor)
      appauthor = appname
    end
    var = roaming ? "CSIDL_APPDATA" : "CSIDL_LOCAL_APPDATA"
    path = normpath(_get_win_folder(var))
    if !isnothing(appname)
      if appauthor != false
        path = joinpath(path, appauthor, appname)
      else
        path = joinpath(path, appname)
      end
    end
  elseif Sys.isapple()
    path = expanduser("~/Library/Application Support/")
    if !isnothing(appname)
      path = joinpath(path, appname)
    end
  else
    path = get(ENV, "XDG_DATA_HOME", expanduser("~/.local/share"))
    if !isnothing(appname)
      path = joinpath(path, appname)
    end
  end
  if !isnothing(appname) && !isnothing(version)
    path = joinpath(path, version)
  end
  return path
end


@doc raw"""
    site_data_dir(appname=nothing, appauthor=nothing; version=nothing,
                  multipath::Bool=false)

Return full path to the user-shared data dir for this application.

- `appname` is the name of application. If `nothing`, just the system directory
  is returned.

- `appauthor` (only used on Windows) is the name of the appauthor or
  distributing body for this application. Typically it is the owning company
  name. This falls back to `appname`. You may pass `false` to disable it.

- `version` is an optional version path element to append to the path. You might
  want to use this if you want multiple versions of your app to be able to run
  independently. If used, this would typically be `"<major>.<minor>"`. Only
  applied when `appname` is present.

- `multipath` is an optional parameter only applicable to *nix which indicates
  that the entire list of data dirs should be returned. By default, the first
  item from `XDG_DATA_DIRS` is returned, or `/usr/local/share/<AppName>`, if
  `XDG_DATA_DIRS` is not set

Typical site data directories are:

| Setting   | Path                                                                         |
|:----------|:-----------------------------------------------------------------------------|
| macOS     | `/Library/Application Support/<AppName>`                                     |
| Unix      | `/usr/local/share/<AppName>` or `/usr/share/<AppName>`                       |
| Win XP    | `C:\Documents and Settings\All Users\Application Data\<AppAuthor>\<AppName>` |
| Win Vista | (Fail! `C:\ProgramData` is a hidden *system* directory on Vista)             |
| Win 7     | `C:\ProgramData\<AppAuthor>\<AppName>` (Hidden, but writeable on Win 7)      |

!!! warning

    Do not use this on Windows. See the Vista-Fail note above for why.
"""
function site_data_dir(appname=nothing, appauthor=nothing; version=nothing,
                       multipath::Bool=false)
  if Sys.iswindows()
    if isnothing(appauthor)
      appauthor = appname
    end
    path = normpath(_get_win_folder("CSIDL_COMMON_APPDATA"))
    if !isnothing(appname)
      if appauthor != false
        path = joinpath(path, appauthor, appname)
      else
        path = joinpath(path, appname)
      end
    end
  elseif Sys.isapple()
    path = expanduser("/Library/Application Support")
    if !isnothing(appname)
      path = joinpath(path, appname)
    end
  else
    # XDG default for $XDG_DATA_DIRS
    # only first, if multipath is False
    pathsep = Base.Filesystem.path_separator
    pathlistsep = Sys.iswindows() ? ';' : ':'
    path = get(ENV, "XDG_DATA_DIRS",
                    join(["/usr/local/share", "/usr/share"], pathlistsep))
    pathlist = [expanduser(rstrip(x, pathsep[1]))
                for x in split(path, pathlistsep)]
    if !isnothing(appname)
      if !isnothing(version)
        appname = joinpath(appname, version)
      end
      pathlist = [join([x, appname], pathsep) for x in pathlist]
    end

    if multipath
      path = join(pathlist, pathlistsep)
    else
      path = pathlist[1]
    end
    return path
  end

  if !isnothing(appname) && !isnothing(version)
    path = joinpath(path, version)
  end
  return path
end


@doc raw"""
    user_config_dir(appname=nothing, appauthor=nothing; version=nothing,
                    roaming::Bool=false)

Return full path to the user-specific config dir for this application.

- `appname` is the name of application. If `nothing`, just the system directory
  is returned.

- `appauthor` (only used on Windows) is the name of the appauthor or
  distributing body for this application. Typically it is the owning company
  name. This falls back to `appname`. You may pass `false` to disable it.

- `version` is an optional version path element to append to the path. You might
  want to use this if you want multiple versions of your app to be able to run
  independently. If used, this would typically be `"<major>.<minor>"`. Only
  applied when `appname` is present.

- `roaming` (default `false`) can be set `true` to use the Windows roaming
  appdata directory. That means that for users on a Windows network setup for
  roaming profiles, this user data will be sync'd on login. See
  [here](http://technet.microsoft.com/en-us/library/cc766489(WS.10).aspx)
  for a discussion of issues.

Typical user config directories are:

| Setting  | Path                                                        |
|:---------|:------------------------------------------------------------|
| macOS    | `~/Library/Preferences/<AppName>`                           |
| Unix     | `~/.config/<AppName>` (or in `XDG_CONFIG_HOME`, if defined) |
| Windows  | same as [`user_data_dir`](@ref)                             |
"""
function user_config_dir(appname=nothing, appauthor=nothing; version=nothing,
                         roaming::Bool=false)
  if Sys.iswindows()
    path = user_data_dir(appname, appauthor; version=nothing, roaming)
  elseif Sys.isapple()
    path = expanduser("~/Library/Preferences/")
    if !isnothing(appname)
      path = joinpath(path, appname)
    end
  else
    path = get(ENV, "XDG_CONFIG_HOME", expanduser("~/.config"))
    if !isnothing(appname)
      path = joinpath(path, appname)
    end
  end
  if !isnothing(appname) && !isnothing(version)
    path = joinpath(path, version)
  end
  return path
end


@doc raw"""
    site_config_dir(appname=nothing, appauthor=nothing; version=nothing,
                    multipath::Bool=false)

Return full path to the user-shared config dir for this application.

- `appname` is the name of application. If `nothing`, just the system directory
  is returned.

- `appauthor` (only used on Windows) is the name of the appauthor or
  distributing body for this application. Typically it is the owning company
  name. This falls back to `appname`. You may pass `false` to disable it.

- `version` is an optional version path element to append to the path. You might
  want to use this if you want multiple versions of your app to be able to run
  independently. If used, this would typically be `"<major>.<minor>"`. Only
  applied when `appname` is present.

- `multipath` is an optional parameter only applicable to *nix which indicates
  that the entire list of config dirs should be returned. By default, the first
  item from `XDG_CONFIG_DIRS` is returned, or `/etc/xdg/<AppName>`, if
  `XDG_CONFIG_DIRS` is not set

Typical site config directories are:

| Setting   | Path                                                                                       |
|:----------|:-------------------------------------------------------------------------------------------|
| macOS     | `/Library/Preferences`                                                            |
| Unix      | `/etc/xdg/<AppName>` or `XDG_CONFIG_DIRS[i]/<AppName>` for each value in `XDG_CONFIG_DIRS` |
| Windows   | same as [`site_data_dir`](@ref)                                                            |
| Win Vista | (Fail! `C:\ProgramData` is a hidden *system* directory on Vista)                           |

!!! warning

    Do not use this on Windows. See the Vista-Fail note above for why.
"""
function site_config_dir(appname=nothing, appauthor=nothing; version=nothing,
                         multipath::Bool=false)
  if Sys.iswindows()
    path = site_data_dir(appname, appauthor)
    if !isnothing(appname) && !isnothing(version)
      path = joinpath(path, version)
    end
  elseif Sys.isapple()
    path = expanduser("/Library/Preferences")
    if !isnothing(appname)
      path = joinpath(path, appname)
    end
    if !isnothing(appname) && !isnothing(version)
      path = joinpath(path, version)
    end
  else
    # XDG default for $XDG_CONFIG_DIRS
    # only first, if multipath is False
    pathsep = Base.Filesystem.path_separator
    pathlistsep = Sys.iswindows() ? ';' : ':'
    path = get(ENV, "XDG_CONFIG_DIRS", "/etc/xdg")
    pathlist = [expanduser(rstrip(x, pathsep[1]))
                for x in split(path, pathlistsep)]
    if !isnothing(appname)
      if !isnothing(version)
        appname = joinpath(appname, version)
      end
      pathlist = [join([x, appname], pathsep) for x in pathlist]
    end
    if multipath
      path = join(pathlist, pathlistsep)
    else
      path = pathlist[1]
    end
  end
  return path
end


@doc raw"""
    user_cache_dir(appname=nothing, appauthor=nothing; version=nothing,
                   opinion::Bool=true)

Return full path to the user-specific cache dir for this application.

- `appname` is the name of application. If `nothing`, just the system directory
  is returned.

- `appauthor` (only used on Windows) is the name of the appauthor or
  distributing body for this application. Typically it is the owning company
  name. This falls back to `appname`. You may pass `false` to disable it.

- `version` is an optional version path element to append to the path. You might
  want to use this if you want multiple versions of your app to be able to run
  independently. If used, this would typically be `"<major>.<minor>"`. Only
  applied when `appname` is present.

- `opinion` (default `true`) can be `false` to disable the appending of `Cache`
  to the base app data dir for Windows. See discussion below.

Typical user cache directories are:

| Setting   | Path                                                                                               |
|:----------|:---------------------------------------------------------------------------------------------------|
| macOS     | `~/Library/Caches/<AppName>`                                                                       |
| Unix      | `~/.cache/<AppName>`  (or in `XDG_CACHE_HOME`, if defined)                                         |
| Win XP    | `C:\Documents and Settings\<username>\Local Settings\Application Data\<AppAuthor>\<AppName>\Cache` |
| Win 7     | `C:\Users\<username>\AppData\Local\<AppAuthor>\<AppName>\Cache`                                    |

On Windows the only suggestion in the MSDN docs is that local settings go in the
`CSIDL_LOCAL_APPDATA` directory. This is identical to the non-roaming app data
dir (the default returned by [`user_data_dir`](@ref)). Apps typically put cache
data somewhere *under* the given dir here. Some examples:

- `...\Mozilla\Firefox\Profiles\<ProfileName>\Cache`
- `...\Acme\SuperApp\Cache\1.0`
"""
function user_cache_dir(appname=nothing, appauthor=nothing; version=nothing,
                        opinion::Bool=true)
  if Sys.iswindows()
    if isnothing(appauthor)
      appauthor = appname
    end
    path = normpath(_get_win_folder("CSIDL_LOCAL_APPDATA"))
    if !isnothing(appname)
      if appauthor != false
        path = joinpath(path, appauthor, appname)
      else
        path = joinpath(path, appname)
      end
      if !isnothing(version)
        path = joinpath(path, version)
      end
      if opinion
        path = joinpath(path, "Cache")
      end
    end
    return path
  elseif Sys.isapple()
    path = expanduser("~/Library/Caches")
    if !isnothing(appname)
      path = joinpath(path, appname)
    end
  else
    path = get(ENV, "XDG_CACHE_HOME", expanduser("~/.cache"))
    if !isnothing(appname)
      path = joinpath(path, appname)
    end
  end
  if !isnothing(appname) && !isnothing(version)
    path = joinpath(path, version)
  end
  return path
end


@doc raw"""
    user_state_dir(appname=nothing, appauthor=nothing; version=nothing,
                   roaming::Bool=false)

Return full path to the user-specific state dir for this application.

- `appname` is the name of application. If `nothing`, just the system directory
  is returned.

- `appauthor` (only used on Windows) is the name of the appauthor or
  distributing body for this application. Typically it is the owning company
  name. This falls back to `appname`. You may pass `false` to disable it.

- `version` is an optional version path element to append to the path. You might
  want to use this if you want multiple versions of your app to be able to run
  independently. If used, this would typically be `"<major>.<minor>"`. Only
  applied when `appname` is present.

- `roaming` (default `false`) can be set `true` to use the Windows roaming
  appdata directory. That means that for users on a Windows network setup for
  roaming profiles, this user data will be sync'd on login. See
  [here](http://technet.microsoft.com/en-us/library/cc766489(WS.10).aspx)
  for a discussion of issues.

Typical user state directories are:

| Setting   | Path                                                        |
|:----------|:------------------------------------------------------------|
| macOS     | same as [`user_data_dir`](@ref)                             |
| Unix      | `~/.local/state/<AppName>` (or `XDG_STATE_HOME` if defined) |
| Windows   | same as [`user_data_dir`](@ref)                             |
"""
function user_state_dir(appname=nothing, appauthor=nothing; version=nothing,
                        roaming::Bool=false)
  if Sys.iswindows() || Sys.isapple()
    path = user_data_dir(appname, appauthor; version=nothing, roaming)
  else
    path = get(ENV, "XDG_STATE_HOME", expanduser("~/.local/state"))
    if !isnothing(appname)
      path = joinpath(path, appname)
    end
  end
  if !isnothing(appname) && !isnothing(version)
    path = joinpath(path, version)
  end
  return path
end


@doc raw"""
    user_log_dir(appname=nothing, appauthor=nothing, version=nothing,
                 opinion::Bool=true)

Return full path to the user-specific log dir for this application.

- `appname` is the name of application. If `nothing`, just the system directory
  is returned.

- `appauthor` (only used on Windows) is the name of the appauthor or
  distributing body for this application. Typically it is the owning company
  name. This falls back to `appname`. You may pass `false` to disable it.

- `version` is an optional version path element to append to the path. You might
  want to use this if you want multiple versions of your app to be able to run
  independently. If used, this would typically be `"<major>.<minor>"`. Only
  applied when `appname` is present.

- `opinion` (default `true`) can be `false` to disable the appending of `Logs`
  to the base app data dir for Windows, and `log` to the base cache dir for
  Unix. See discussion below.

Typical user log directories are:

| Setting   | Path                                                                                               |
|:----------|:---------------------------------------------------------------------------------------------------|
| macOS     | `~/Library/Logs/<AppName>`                                                                       |
| Unix      | `~/.cache/<AppName>/log`  (or under `XDG_CACHE_HOME`, if defined)                                         |
| Win XP    | `C:\Documents and Settings\<username>\Local Settings\Application Data\<AppAuthor>\<AppName>\Logs` |
| Win 7     | `C:\Users\<username>\AppData\Local\<AppAuthor>\<AppName>\Logs`                                    |

On Windows the only suggestion in the MSDN docs is that local settings go in the
`CSIDL_LOCAL_APPDATA` directory.
"""
function user_log_dir(appname=nothing, appauthor=nothing; version=nothing,
                      opinion::Bool=true)
  if Sys.isapple()
    path = joinpath(expanduser("~/Library/Logs"), appname)
  elseif Sys.iswindows()
    path = user_data_dir(appname, appauthor; version)
    version = nothing
    if opinion
      path = joinpath(path, "Logs")
    end
  else
    path = user_cache_dir(appname, appauthor; version)
    version = nothing
    if opinion
      path = joinpath(path, "log")
    end
  end
  if !isnothing(appname) && !isnothing(version)
    path = joinpath(path, version)
  end
  return path
end


"""
    AppDir(appname=nothing, appauthor=nothing, version=nothing,
           roaming::Bool=false, multipath::Bool=false)

Convenience wrapper for getting application dirs, with the following fields:

- `data`: the output of [`user_data_dir`](@ref)
- `site_data`: the output of [`site_data_dir`](@ref)
- `config`: the output of [`user_config_dir`](@ref)
- `site_config`: the output of [`site_config_dir`](@ref)
- `cache`: the output of [`user_cache_dir`](@ref)
- `state`: the output of [`user_state_dir`](@ref)
- `log`: the output of [`user_log_dir`](@ref)
"""
struct AppDir
  data::String
  site_data::String
  config::String
  site_config::String
  cache::String
  state::String
  log::String

  function AppDir(appname=nothing, appauthor=nothing; version=nothing,
                  roaming::Bool=false, multipath::Bool=false)
    new(
        user_data_dir(appname, appauthor; version, roaming),
        site_data_dir(appname, appauthor; version, multipath),
        user_config_dir(appname, appauthor; version, roaming),
        site_config_dir(appname, appauthor; version, multipath),
        user_cache_dir(appname, appauthor; version),
        user_state_dir(appname, appauthor; version, roaming),
        user_log_dir(appname, appauthor; version),
    )
  end
end


#---- internal support stuff

function _get_win_folder(csidl_name)
  # From https://github.com/JuliaLang/IJulia.jl/blob/8710cd4bc1adabfacb8d9caec56332e36daa1f90/deps/kspec.jl#L12-L17
  csidl_const = Dict(
      "CSIDL_APPDATA" =>        UInt16(26),
      "CSIDL_COMMON_APPDATA" => UInt16(35),
      "CSIDL_LOCAL_APPDATA" =>  UInt16(28),
  )[csidl_name]

  path = zeros(UInt16, 1024)
  result = ccall((:SHGetFolderPathW,:shell32), stdcall, Cint,
          (Ptr{Cvoid},Cint,Ptr{Cvoid},Cint,Ptr{UInt16}),C_NULL,csidl_const,C_NULL,0,path)

  if result == 0
    return transcode(String, resize!(path, findfirst(iszero, path) - 1))
  end

  # Fallback to ENV
  env_var_name = Dict(
      "CSIDL_APPDATA" => "APPDATA",
      "CSIDL_COMMON_APPDATA" => "ALLUSERSPROFILE",
      "CSIDL_LOCAL_APPDATA" => "LOCALAPPDATA",
  )[csidl_name]

  return get(ENV, env_var_name, "")
end

end
