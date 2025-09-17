{
  lib,
  config,
  ...
}:

{
  options = {
    my-dyn-dns = with lib.types; {
      enable = lib.mkEnableOption "Use Dynamic DNS";

      dynamic_domain = lib.mkOption {
        default = "";
        type = commas; # need to merge in a comma-separated list of addresses
        description = "Domain/subdomain to use for dynamic DNS service";
      };
    };
  };

  config = lib.mkIf config.my-dyn-dns.enable {

    # ****** SERVICE ******
    services.cloudflare-dyndns = {
      enable = true;
      proxied = false; # do not proxy DNS queries via Cloudflare, issues with Wireguard
      deleteMissing = true; # delete A record when I cannot infer my own IP; same for AAAA records and IPv6
      domains = lib.strings.splitString "," config.my-dyn-dns.dynamic_domain;
      apiTokenFile = config.sops.secrets."cloudflare/api-key".path;
    };

    # ****** SECRETS ******
    sops.secrets."cloudflare/api-key" = { };

  };
}
