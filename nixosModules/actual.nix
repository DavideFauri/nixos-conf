{ lib
, config
, ...
}:

{
  imports = [
    ./dyn_dns.nix
  ];

  options = {
    my-actual = with lib.types; {
      enable = lib.mkEnableOption "my Actual setup";

      listen_address = lib.mkOption {
        default = "0.0.0.0";
        type = uniq str;
        description = "Actual server address (default: listen on all interfaces)";
      };
      listen_port = lib.mkOption {
        default = 5006;
        type = int;
        description = "Actual server port";
      };
      use_https = lib.mkEnableOption "enable HTTPS for Actual server (requires cert and key files)";

      dataDir = lib.mkOption {
        default = "/var/lib/actual";
        type = uniq str;
        description = "Directory to store Actual data";
      };

      dynamic_domain = lib.mkOption {
        default = null;
        type = nullOr str;
        description = "Domain/subdomain to use for dynamic DNS service";
      };
    };
  };

  config = lib.mkIf config.my-actual.enable
    {

      # ****** SERVICE ******
      services.actual = {
        enable = true;
        openFirewall = true;
        settings = {

          hostname = config.my-actual.listen_address;
          port = config.my-actual.listen_port;

          #dataDir = config.my-actual.dataDir;
          #serverFiles = "${config.my-actual.dataDir}/server-files";
          #userFiles = "${config.my-actual.dataDir}/user-files";

          https = lib.mkIf config.my-actual.use_https {
            #          cert = /run/credentials/actual.service/public-cert;
            #          key = /run/credentials/actual.service/private-key;
            cert = "/run/credentials/actual.service/public-cert"; #config.sops.secrets."actual/public-cert".path;
            key = "/run/credentials/actual.service/private-key"; #config.sops.secrets."actual/private-key".path;
          };
        };
      };

      # ****** FOLDER PERMISSIONS ******

      # the "actual" user created by the service does not have permissions to the data directory, so I hope the target folder is 777
      # users.groups.actual = { }; # must create it beforehand so that it exists when the tmpfiles are applied
      # systemd.tmpfiles.settings."00-actual"."${config.my-actual.dataDir}".Z = {
      # mode = "0770";
      # group = "actual";
      # };

      # ****** SECRETS ******
      sops.secrets."actual/public-cert" = { };
      sops.secrets."actual/private-key" = { };

      # since the service uses dynamic users, this is a trick
      systemd.services.actual.serviceConfig.LoadCredential = [
        "public-cert:${config.sops.secrets."actual/public-cert".path}"
        "private-key:${config.sops.secrets."actual/private-key".path}"
      ];

      # ****** DYNAMIC DNS ******
      my-dyn-dns = lib.mkIf (config.my-actual.dynamic_domain != null) {
        enable = true;
        dynamic_domain = config.my-actual.dynamic_domain;
      };

      # ***** VPN *****
      my-wireguard = lib.mkIf config.my-wireguard.enable {
        allow_TCP = [ config.my-actual.listen_port ];
      };
    };
}
