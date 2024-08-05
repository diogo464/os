{ pkgs, ... }:
with pkgs;
	rustPlatform.buildRustPackage rec {
		pname = "dotup";
		version = "0.3.0";
		
		src = fetchGit {
			url = "https://git.d464.sh/code/dotup";
			rev = "e62270b966a2cca1cffbb790cdc6a5130fd81c49";
		};

		RUSTC_BOOTSTRAP = true;
		cargoHash = "sha256-L4GRRkMmm8x5ozPquJWrevaaKknCWNSKcyEEw8CqPc0=";
	}
