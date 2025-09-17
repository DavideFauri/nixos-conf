{
  pkgs,
  lib,
  config,
  ...
}:

{
  imports = [
    ./dyn_dns.nix
  ];

  options = {
    my-wireguard = with lib.types; {
      enable = lib.mkEnableOption "my wireguard setup";

      listen_port = lib.mkOption {
        default = 51820;
        type = int;
        description = "Wireguard listen port";
      };
      dynamic_domain = lib.mkOption {
        default = "";
        type =  str;
        description = "Domain/subdomain to use for dynamic DNS service";
      };

      vpn_interface = lib.mkOption {
        default = "wg0";
        type = uniq str;
        description = "VPN interface/network name to be used";
      };
      ext_interface = lib.mkOption {
        default = "eth0";
        type = uniq str;
        description = "external interface";
      };

      allow_TCP = lib.mkOption {
        default = [ ];
        type = listOf int;
        description = "allowed TCP ports for incoming traffic to the VPN";
      };
      allow_UDP = lib.mkOption {
        default = [ ];
        type = listOf int;
        description = "allowed UDP ports for incoming traffic to the VPN";
      };
    };
  };

  config = lib.mkIf config.my-wireguard.enable {

    # ****** SERVICE ******
    networking.wireguard = {
      enable = true;
      interfaces.${config.my-wireguard.vpn_interface} = {
        listenPort = config.my-wireguard.listen_port; # changed from default Wireguard port
        ips = [ "10.0.0.1/14" ]; # IP and subnet on server's side of the tunnel
        # 10.0 for machines and servers
        # 10.1 for close family
        # 10.2 for extended family
        # 10.3 for guests
        dynamicEndpointRefreshSeconds = 300;

        # when setting up the tunnel, add a route from the wg0 network to the internet (all incoming traffic exits from the server)
        # all connected clients must set my router as DNS server (or pick their own)
        #        postSetup = ''
        #          ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s 10.100.0.0/24 -o eth0 -j MASQUERADE
        #        '';
        # tear down the route when tunnel closes
        #        postShutdown = ''
        #          ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s 10.100.0.0/24 -o eth0 -j MASQUERADE
        #        '';

        privateKeyFile = "/run/credentials/wireguard.service/server-key";
        generatePrivateKeyFile = true; # set up the key automatically

        peers = [
          # list of peers that can connect to this server
          {
            name = "wireguard_server";
            publicKey = "FLkFVp+JiGFk3G2apurcdszVA1F81iRDNhoP8v/n3EE="; # find it by converting the private one
            allowedIPs = [ "10.0.0.1/32" ];
          }
          {
            name = "Fairphone";
            publicKey = "pzV8XqeG7/2IWBc9xVYnXhEg7rxOFqbQfDHsKP+Vzkk=";
            allowedIPs = [ "10.1.0.1/32" ];
          }
          {
            name = "Giulia_android";
            publicKey = "95XY6Sk64QseFOxuv4TnLW4wXb5KVlISKVOis49PPDs=";
            allowedIPs = [ "10.1.1.1/32" ];
          }
        ];
      };
    };


    # ****** SECRETS ******
    sops.secrets."wireguard/server-key" = {};

    # since the service uses dynamic users, this is a trick
    systemd.services.wireguard.serviceConfig.LoadCredential = [
      "server-key:${config.sops.secrets."wireguard/server-key".path}"
    ];

    # ****** SUPPORTING PACKAGES ******
    environment.systemPackages = with pkgs; [
      qrencode # to export configuration files; ex. sudo wg show-conf > qrencode -t ansiutf8; or ex. qrencode -t png -o client-qr.png -r wg-client.conf
      openssl # to produce certificates for internal servers that require https; ex. openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout selfhost.key -out selfhost.crt
    ];

    # ****** NAT BETWEEN NETWORKS ******
    networking.nat = {
      enable = true;
      internalInterfaces = [ config.my-wireguard.vpn_interface ];
      externalInterface = config.my-wireguard.ext_interface;
    };

    # ****** FIREWALL ******
    networking.firewall = {
      enable = true;
      interfaces.${config.my-wireguard.ext_interface} = {
        allowedUDPPorts = [ config.my-wireguard.listen_port ];
      };
      interfaces.${config.my-wireguard.vpn_interface} = {
        allowedTCPPorts = config.my-wireguard.allow_TCP;
        allowedUDPPorts = config.my-wireguard.allow_UDP;
      };
    };



    # ****** DYNAMIC DNS ******
    my-dyn-dns = lib.mkIf (config.my-wireguard.dynamic_domain != ""){
      enable = true;
      dynamic_domain = config.my-wireguard.dynamic_domain;
    };


  };
}
