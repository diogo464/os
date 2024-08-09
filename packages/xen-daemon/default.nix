{ buildGoModule, lib, ... }:
buildGoModule
{
  pname = "xen-daemon";
  version = "0.0.0";
  src = lib.cleanSource ./.;
  vendorHash = "sha256-n+UuXOybCdy/IWNoDuF7dPv/1mjmeFoje7qPXRnmPaM=";
}

