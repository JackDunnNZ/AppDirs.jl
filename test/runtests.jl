using AppDirs
using Test

@testset "default paths" begin
  if Sys.isapple()
    paths = AppDirs.AppDir("J1", "J2")
    @test paths.data == expanduser("~/Library/Application Support/J1")
    @test paths.site_data == "/Library/Application Support/J1"
    @test paths.config == expanduser("~/Library/Preferences/J1")
    @test paths.site_config == "/Library/Preferences/J1"
    @test paths.cache == expanduser("~/Library/Caches/J1")
    @test paths.state == expanduser("~/Library/Application Support/J1")
    @test paths.log == expanduser("~/Library/Logs/J1")

    paths = AppDirs.AppDir("J1", "J2", version="V1")
    @test paths.data == expanduser("~/Library/Application Support/J1/V1")
    @test paths.site_data == "/Library/Application Support/J1/V1"
    @test paths.config == expanduser("~/Library/Preferences/J1/V1")
    @test paths.site_config == "/Library/Preferences/J1/V1"
    @test paths.cache == expanduser("~/Library/Caches/J1/V1")
    @test paths.state == expanduser("~/Library/Application Support/J1/V1")
    @test paths.log == expanduser("~/Library/Logs/J1/V1")

  elseif Sys.islinux()
    withenv(
        "XDG_DATA_HOME" => nothing,
        "XDG_DATA_DIRS" => nothing,
        "XDG_CONFIG_HOME" => nothing,
        "XDG_CONFIG_DIRS" => nothing,
        "XDG_CACHE_HOME" => nothing,
        "XDG_STATE_HOME" => nothing,
    ) do
      paths = AppDirs.AppDir("J1", "J2")
      @test paths.data == expanduser("~/.local/share/J1")
      @test paths.site_data == "/usr/local/share/J1"
      @test paths.config == expanduser("~/.config/J1")
      @test paths.site_config == "/etc/xdg/J1"
      @test paths.cache == expanduser("~/.cache/J1")
      @test paths.state == expanduser("~/.local/state/J1")
      @test paths.log == expanduser("~/.cache/J1/log")

      paths = AppDirs.AppDir("J1", "J2", version="V1")
      @test paths.data == expanduser("~/.local/share/J1/V1")
      @test paths.site_data == "/usr/local/share/J1/V1"
      @test paths.config == expanduser("~/.config/J1/V1")
      @test paths.site_config == "/etc/xdg/J1/V1"
      @test paths.cache == expanduser("~/.cache/J1/V1")
      @test paths.state == expanduser("~/.local/state/J1/V1")
      @test paths.log == expanduser("~/.cache/J1/V1/log")
    end
  elseif Sys.iswindows()
    home = ENV["USERPROFILE"]

    paths = AppDirs.AppDir("J1", "J2")
    @test paths.data == "$home\\AppData\\Local\\J2\\J1"
    @test paths.site_data == "C:\\ProgramData\\J2\\J1"
    @test paths.config == "$home\\AppData\\Local\\J2\\J1"
    @test paths.site_config == "C:\\ProgramData\\J2\\J1"
    @test paths.cache == "$home\\AppData\\Local\\J2\\J1\\Cache"
    @test paths.state == "$home\\AppData\\Local\\J2\\J1"
    @test paths.log == "$home\\AppData\\Local\\J2\\J1\\Logs"

    paths = AppDirs.AppDir("J1", "J2", version="V1")
    @test paths.data == "$home\\AppData\\Local\\J2\\J1\\V1"
    @test paths.site_data == "C:\\ProgramData\\J2\\J1\\V1"
    @test paths.config == "$home\\AppData\\Local\\J2\\J1\\V1"
    @test paths.site_config == "C:\\ProgramData\\J2\\J1\\V1"
    @test paths.cache == "$home\\AppData\\Local\\J2\\J1\\V1\\Cache"
    @test paths.state == "$home\\AppData\\Local\\J2\\J1\\V1"
    @test paths.log == "$home\\AppData\\Local\\J2\\J1\\V1\\Logs"

    paths = AppDirs.AppDir("J1", "J2", roaming=true)
    @test paths.data == "$home\\AppData\\Roaming\\J2\\J1"
    @test paths.site_data == "C:\\ProgramData\\J2\\J1"
    @test paths.config == "$home\\AppData\\Roaming\\J2\\J1"
    @test paths.site_config == "C:\\ProgramData\\J2\\J1"
    @test paths.cache == "$home\\AppData\\Local\\J2\\J1\\Cache"
    @test paths.state == "$home\\AppData\\Roaming\\J2\\J1"
    @test paths.log == "$home\\AppData\\Local\\J2\\J1\\Logs"

    paths = AppDirs.AppDir("J1", "J2", roaming=true, version="V1")
    @test paths.data == "$home\\AppData\\Roaming\\J2\\J1\\V1"
    @test paths.site_data == "C:\\ProgramData\\J2\\J1\\V1"
    @test paths.config == "$home\\AppData\\Roaming\\J2\\J1\\V1"
    @test paths.site_config == "C:\\ProgramData\\J2\\J1\\V1"
    @test paths.cache == "$home\\AppData\\Local\\J2\\J1\\V1\\Cache"
    @test paths.state == "$home\\AppData\\Roaming\\J2\\J1\\V1"
    @test paths.log == "$home\\AppData\\Local\\J2\\J1\\V1\\Logs"

    paths = AppDirs.AppDir("J1")
    @test paths.data == "$home\\AppData\\Local\\J1\\J1"
    @test paths.site_data == "C:\\ProgramData\\J1\\J1"
    @test paths.config == "$home\\AppData\\Local\\J1\\J1"
    @test paths.site_config == "C:\\ProgramData\\J1\\J1"
    @test paths.cache == "$home\\AppData\\Local\\J1\\J1\\Cache"
    @test paths.state == "$home\\AppData\\Local\\J1\\J1"
    @test paths.log == "$home\\AppData\\Local\\J1\\J1\\Logs"

    paths = AppDirs.AppDir("J1", false)
    @test paths.data == "$home\\AppData\\Local\\J1"
    @test paths.site_data == "C:\\ProgramData\\J1"
    @test paths.config == "$home\\AppData\\Local\\J1"
    @test paths.site_config == "C:\\ProgramData\\J1"
    @test paths.cache == "$home\\AppData\\Local\\J1\\Cache"
    @test paths.state == "$home\\AppData\\Local\\J1"
    @test paths.log == "$home\\AppData\\Local\\J1\\Logs"
  end
end

@testset "can override with env vars" begin
  if Sys.islinux()
    withenv(
        "XDG_DATA_HOME" => "A",
        "XDG_DATA_DIRS" => "B",
        "XDG_CONFIG_HOME" => "C",
        "XDG_CONFIG_DIRS" => "D",
        "XDG_CACHE_HOME" => "E",
        "XDG_STATE_HOME" => "F",
    ) do
      paths = AppDirs.AppDir("Julia")
      @test paths.data == "A/Julia"
      @test paths.site_data == "B/Julia"
      @test paths.config == "C/Julia"
      @test paths.site_config == "D/Julia"
      @test paths.cache == "E/Julia"
      @test paths.state == "F/Julia"
      @test paths.log == "E/Julia/log"
    end
  end
end

@testset "multipath on linux" begin
  if Sys.islinux()
    withenv(
        "XDG_DATA_DIRS" => "/usr/local/share:/usr/share",
        "XDG_CONFIG_DIRS" => "/usr/local/config:/usr/config",
    ) do
      paths = AppDirs.AppDir("Julia", multipath=true)
      @test paths.site_data == "/usr/local/share/Julia:/usr/share/Julia"
      @test paths.site_config == "/usr/local/config/Julia:/usr/config/Julia"

      paths = AppDirs.AppDir("Julia", multipath=false)
      @test paths.site_data == "/usr/local/share/Julia"
      @test paths.site_config == "/usr/local/config/Julia"
    end
  end
end
