{ pkgs, ... }:
with pkgs;
rustPlatform.buildRustPackage rec {
  pname = "wgs";
  version = "0.2.0";

  src = fetchGit {
    url = "https://git.d464.sh/code/wireguard-server";
    rev = "2bfecfdb9ae22e47fd5af6ba061163e8c8933eb9";
  };

  RUSTC_BOOTSTRAP = true;
  cargoHash = "sha256-L4GRRkMmm8x5ozPquJWrevaaKknCWNSKcyEEw8CqPc0=";
  cargoLock.lockFile = / + src + ./Cargo.lock";
}

