{
  description = "A template that shows all standard flake outputs";

  inputs.nixpkgsRegistry.url = "github:NixOS/nixpkgs/nixos-24.05";

  outputs = { self, nixpkgs, ... }: {
        nixosConfigurations.nas = nixpkgs.lib.nixosSystem {
                system = "x86_64-linux";
                modules = [ ./machines/nas/configuration.nix ];
        };
  };
}
