{
  description = "A template that shows all standard flake outputs";

  inputs.nixpkgsRegistry.url = "github:NixOS/nixpkgs/nixos-24.05";
  inputs.wireguard-server.url = "git+https://git.d464.sh/code/wireguard-server";
  inputs.dotup.url = "git+https://git.d464.sh/code/dotup";

  outputs = inputs@{ self, nixpkgs, wireguard-server, dotup, ... }:
    let
      system = "x86_64-linux";
      overlays = [
        (final: prev: { wireguard-server = wireguard-server.defaultPackage.x86_64-linux; })
        (final: prev: { wireguard-server = dotup.defaultPackage.x86_64-linux; })
      ];
    in
    {
      nixosConfigurations.nas = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [ ./machines/nas/configuration.nix ];
      };
      nixosConfigurations.xen = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          { nixpkgs.overlays = overlays; }
          ./machines/xen/configuration.nix
        ];
      };
    };
}

