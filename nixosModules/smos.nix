{ lib
, config
, inputs
, system
, ...
}:

let
  smosModule = inputs.smos.nixosModules.${system}.default;
in
{
  imports = [
    smosModule
    ./dyn_dns.nix
  ];

  options = {
    my-smos-server = with lib.types; {
      enable = lib.mkEnableOption "my smos setup";

      listen_address = lib.mkOption {
        default = "0.0.0.0";
        type = uniq str;
        description = "smos server address (default: listen on all interfaces)";
      };
      api_port = lib.mkOption {
        default = 8402;
        type = int;
        description = "smos API server port: not necessarily to be exposed, can be web only";
      };
      web_port = lib.mkOption {
        default = 8403;
        type = int;
        description = "smos web server port";
      };
      dynamic_domain = lib.mkOption {
        default = null;
        type = nullOr str;
        description = "Domain/subdomain to use for dynamic DNS service";
      };
    };
  };

  config = lib.mkIf config.my-smos-server.enable {
    services.smos.production = {
      enable = true;
      api-server = {
        enable = true;
        hosts = [ config.my-smos-server.listen_address ];
        config.port = config.my-smos-server.api_port;
        openFirewall = true;
      };
      web-server = {
        enable = true;
        config = {
          api-url = "${config.my-smos-server.listen_address}:${toString config.my-smos-server.api_port}";
          web-url = "${config.my-smos-server.listen_address}";
          port = config.my-smos-server.web_port;
        };
        openFirewall = true;
      };
    };

    # ****** DYNAMIC DNS ******
    my-dyn-dns = lib.mkIf (config.my-smos-server.dynamic_domain != null) {
      enable = true;
      dynamic_domain = config.my-smos-server.dynamic_domain;
    };
  };
}
