{
  lib,
  config,
  ...
}:

{

  imports = [
    ./dyn_dns.nix
  ];

  options = {
    my-immich = with lib.types; {
      enable = lib.mkEnableOption "my Immich setup";

      listen_address = lib.mkOption {
        default = "0.0.0.0";
        type = uniq str;
        description = "Immich server address";
      };
      listen_port = lib.mkOption {
        default = 2283;
        type = int;
        description = "Immich server port";
      };

      dynamic_domain = lib.mkOption {
        default = "";
        type = str;
        description = "Domain/subdomain to use for dynamic DNS service";
      };

      use_hardware = lib.mkEnableOption "use hardware for acceleration and machine learning";

    };
  };

  config = lib.mkIf config.my-immich.enable {

    services.immich = lib.mkMerge [
      {
        enable = true;
        host = config.my-immich.listen_address;
        port = config.my-immich.listen_port;
        openFirewall = true;
        environment = {
          TZ = "Europe/Rome";
        };
      }

      (lib.mkIf config.my-immich.use_hardware {
        accelerationDevices = null; # use all available devices
        machine-learning = {
          enable = true;
        };
      })
    ];

    users.users.immich.extraGroups = lib.mkIf config.my-immich.use_hardware [
      "video"
      "render"
    ];

    # ****** DYNAMIC DNS ******
    my-dyn-dns = lib.mkIf (config.my-immich.dynamic_domain != "") {
      enable = true;
      dynamic_domain = config.my-immich.dynamic_domain;
    };

  };
}
