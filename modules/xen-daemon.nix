{ config, pkgs, ... }:
let pkg = pkgs.callPackage ../packages/xen-daemon { }; in
{
  environment.systemPackages = with pkgs; [
    pkg
    nftables
  ];

  systemd.services.xen-daemon = {
    enable = true;
    path = [ pkg pkgs.nftables ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${pkg}/bin/xend";
      ExecRestart = "always";
    };
  };
}

