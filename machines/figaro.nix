{ pkgs, inputs, ... }:

{
  networking.hostName = "figaro";

  imports = [
    # Include the results of the hardware scan.
    <nixos-hardware/framework/16-inch/7040-amd>
    ./figaro-hardware-configuration.nix

    # Exportable configuration for VPN server
    ../nixosModules/wireguard.nix

    # Exportable configuration for Immich server
    ../nixosModules/immich.nix

    # Exportable configuration for Actual server
    ../nixosModules/actual.nix
  ];

  environment.systemPackages = with pkgs; [
    kitty # default terminal for hyperland, that's why I'm installing it here and not in home manager
    gnomeExtensions.tray-icons-reloaded
    #    waybar # for wayland

    nixd # language server for nix
    nixfmt-rfc-style # formatter for nix

    nvtopPackages.amd
    inputmodule-control # LED framework lights
  ];

  nix.nixPath = [ "nixpkgs=${inputs.nixpkgs}" ]; # needed for nixd when using flakes

  programs = {
    #    hyprland.enable = true;
    #    hyprland.xwayland.enable = true;
    firefox.enable = true;
    steam.enable = true;
  };

  # My flakes
  my-wireguard = {
    enable = true;
    listen_port = 51280;
    dynamic_domain = "vpn.fauri.family";

    vpn_interface = "wg0";
    ext_interface = "wlp4s0";

    allow_TCP = [
      80
      443
      22083 # Immich
      5006 # Actual
      8080
    ];
    allow_UDP = [ 53 ];
  };

  my-immich = {
    enable = true;
    listen_port = 22083;
#    dynamic_domain = "photo.fauri.family";

    use_hardware = true;
  };

  my-actual = {
    enable = true;
    listen_port = 5006;
    use_https = true;

    dataDir = "/var/lib/actual";
  };

  # Bootloader
  boot.loader = {
    systemd-boot = {
      enable = true;
      configurationLimit = 10; # used to prevent boot partition running out of space
    };
    efi.canTouchEfiVariables = true;
  };
  boot.initrd.systemd.enable = true;

  # Networking
  networking = {
    networkmanager.enable = true;

    nameservers = [
      "1.1.1.1"
      "9.9.9.9"
    ];
  };

  # Desktop managers
  services.xserver.enable = true; # X11 windowing system
  services.xserver.desktopManager.gnome.enable = true; # GNOME desktop manager
  services.xserver.displayManager.gdm.enable = true; # GNOME display manager

  #  services.displayManager.gdm.wayland = true; # allow GNOME to run on Wayland instead of Xserver

  # ------------
  # for Davinci Resolve, see:
  # https://nixos.wiki/wiki/DaVinci_Resolve
  # https://nixos.wiki/wiki/AMD_GPU

  boot.initrd.kernelModules = [ "amdgpu" ];

  services.xserver.videoDrivers = [ "amdgpu" ];

  systemd.tmpfiles.rules = [
    "L+    /opt/rocm/hip   -    -    -     -    ${pkgs.rocmPackages.clr}"
  ];

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      rocmPackages.clr.icd
      #      rocmPackages.clr
      #      rocmPackages.rocminfo
      #      rocmPackages.rocm-runtime
    ];
  };

  # -----------

  # hint to Electron apps so that they prefer using Wayland:
  #  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # ****** SERVICES ******

  # Enable the OpenSSH daemon.
  services.openssh = {
    settings = {
      PasswordAuthentication = true;
      AllowUsers = [ "davide" ];
    };
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Bluetooth
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # Enable firmware updating (command = fwupdmgr update)
  services.fwupd.enable = true;

  # Enable tunables to optimize battery life
  services.tlp.enable = true;
  services.power-profiles-daemon.enable = false; # because TLP conflicts, it must be turned off explicitly

  # ****** PRINTING ******

  services.printing = {
    enable = true;
    drivers = with pkgs; [
      cups-filters
      cups-browsed
      gutenprint
    ];
  };

  # autodiscovery of printers, uses port 5353
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  # ****** AUTOLOGIN ******

  services.displayManager.autoLogin = {
    enable = true;
    user = "davide";
  };

  # Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
  # TODO: remove these lines in the next stable version https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-3158958974
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

  # ****** LOCALE PREFERENCES ******

  services.xserver = {
    xkb = {
      # Configure keymap in X11
      layout = "it";
      variant = "winkeys";
    };
  };

  console.keyMap = "it2"; # Configure console keymap

  # ****** SOUND PREFERENCES ******

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

  };

  # ****** END ******

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?

}
