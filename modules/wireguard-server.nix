{ config, pkgs, ... }:
let pkg = pkgs.callPackage ../packages/xen-daemon { }; in
{
  environment.systemPackages = with pkgs; [
    wireguard-server
  ];

  systemd.services.wireguard-server = {
    enable = true;
    path = with pkgs; [ wireguard-server ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Environment = [
        "WGS_TOKEN=infra-wireguard"
        "WGS_PRIVATE_KEY=iK99lOCzQoSUwCYrnOiuzjLlwcN7y225sha813CvflM="
      ];
      ExecStart = ''${pkgs.wireguard-server}/bin/wgs server \
        --network 10.0.0.0/8 \
        --config-directory /etc/wgs \
        --dns-server 10.0.0.1 \
        --server-endpoint ipv4.d464.sh:51820 \
        --address 10.0.0.1:3000
      '';
      ExecRestart = "always";
    };
  };
}

