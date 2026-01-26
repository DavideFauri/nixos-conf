{ pkgs, ... }:

let
in
{
  home.username = "davide";
  home.homeDirectory = "/home/davide";
  home.stateVersion = "24.05"; # You should not change this value, even if you update Home Manager.

  imports = [
    #    ../homeModules/python.nix
    #    ../homeModules/kitty.nix
    ../homeModules/fish.nix
    ../homeModules/starship.nix
    #    ../homeModules/smos.nix
  ];

  home.packages = with pkgs; [

    # Windows emulation
    wine
    winetricks

    # Command line
    powertop
    ripgrep

    # Android stuff
    android-tools # Apparently I need to 'sudo (which adb) devices
    scrcpy
    adb-sync

    # Apps
    keepass
    maestral
    maestral-gui # dropbox client
    deluge
    libreoffice-fresh
    freeplane
    chromium
    zoom-us

    # Media - Video
    yt-dlp # download youtube
    catt # stream to chromecast
    stremio
    vlc
    davinci-resolve
    obs-studio
    handbrake
    navidrome

    # Media - Image
    gthumb
    krita

    # Media - Audio
    strawberry

    # Games
    dolphin-emu
    mame
    scummvm
    heroic
    vesktop
    #wiiuse
    #wiiload
    #wiimms-iso-tools

    # Reading and writing
    calibre
    obsidian
    tectonic
    hieroglyphic
    unstable.tex-fmt # LaTeX formatter

    # Family finance
    portfolio

    # AI stuff
    #    ollama

    # Development
    gh
    vscode
    waydroid
    waydroid-helper
    #cargo
    #    julia
    #    unstable.haskellPackages.ghcup # does not work

    # Security
    #    maltego
    #    burpsuite
    wireshark
    #ghidra
    #ghidra-extensions.gnudisassembler
    #ghidra-extensions.ghidraninja-ghidra-scripts
    #ghidra-extensions.machinelearning
    aircrack-ng # cracking wifi and having fun
    kismet # GUI for aircrack-ng
    ath9k-htc-blobless-firmware # drivers of external antenna

  ];

  programs = {
    autojump.enable = true;
    starship.enable = true;
    #    smos.enable = false;
  };

  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  home.sessionVariables = {
    EDITOR = "nano";
  };

}
