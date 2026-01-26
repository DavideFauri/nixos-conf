{ pkgs, inputs, ... }:

{
  nix.settings.experimental-features = [
    "flakes"
    "nix-command"
  ];
  nixpkgs.config.allowUnfree = true;

  # ****** DEFAULT PACKAGES ******
  environment.systemPackages = with pkgs; [
    home-manager
    git
    sops # secrets management

    htop
    nethogs
    tree
    curl
    tmux
  ];

  programs = {
    fish.enable = true;
  };


  # ****** SECRETS ******
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];
  sops = {
    defaultSopsFile = ../secrets/secrets.yaml;
    validateSopsFiles = false;
    age = {
      sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ]; # auto import the hosts ssh key
      #keyFile = "/private/sops/age/keys.txt"; # my private age key
      #generateKey = true; # generate the above file if missing
    };
  };

  # ****** USERS ******
  users.users = {
    davide = {
      isNormalUser = true;
      description = "Davide";
      extraGroups = [
        "networkmanager"
        "wheel"
      ];
      shell = pkgs.fish;
    };
  };

  nix.settings.trusted-users = [
    "root"
    "davide"
  ];

  # ****** SSH ACCESS ******
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "yes";
    };
  };

  # ****** AUTO MAINTENANCE ******

  system.autoUpgrade = {
    enable = true;
    persistent = true;
    dates = "weekly";
    operation = "switch";
    allowReboot = false;

    flake = inputs.self.outPath;

    flags = [
      "--impure"
      "--recreate-lock-file" # Deprecated, but maybe they introduce it again https://discourse.nixos.org/t/best-practices-for-auto-upgrades-of-flake-enabled-nixos-systems/31255/18
    ];
  };

  nix.settings.auto-optimise-store = true;

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  # ****** LOCALE SETTINGS ******

  time.timeZone = "Europe/Rome";

  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "it_IT.UTF-8";
      LC_IDENTIFICATION = "it_IT.UTF-8";
      LC_MEASUREMENT = "it_IT.UTF-8";
      LC_MONETARY = "it_IT.UTF-8";
      LC_NAME = "it_IT.UTF-8";
      LC_NUMERIC = "it_IT.UTF-8";
      LC_PAPER = "it_IT.UTF-8";
      LC_TELEPHONE = "it_IT.UTF-8";
      LC_TIME = "it_IT.UTF-8";
    };
  };

}
