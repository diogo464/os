# Edit this configuration file to define what should be installed on your system.  Help is available in the
# configuration.nix(5) man page and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{ imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix ];

  # Bootloader.
  boot.loader.grub.enable = true; boot.loader.grub.device = "/dev/vda"; boot.loader.grub.useOSProber = true;

        virtualisation.containerd.enable = true;
        virtualisation.oci-containers.containers.gitea = {
                image = "docker.io/gitea/gitea:1.21.3";
                environment = {
                        GITEA__database__DBTYPE="sqlite3";
                        GITEA__repository__ENABLE_PUSH_CREATE_USER="true";
                        GITEA__repository__ENABLE_PUSH_CREATE_ORG="true";
                        GITEA__repository__DEFAULT_BRANCH="main";
                        GITEA__repository__DEFAULT_REPO_UNITS="repo.code,repo.releases,repo.issues,repo.pulls,repo.wiki,repo.projects,repo.packages,repo.actions";
                        GITEA__repository__DEFAULT_PRIVATE="public";
                        GITEA__repository__DEFAULT_PUSH_CREATE_PRIVATE="false";
                        GITEA__ui_0x2E_user__REPO_PAGING_NUM="25";
                        GITEA__server__PROTOCOL="http";
                        GITEA__server__HTTP_PORT="3000";
                        GITEA__server__DOMAIN="git.d464.sh";
                        GITEA__server__ROOT_URL="http://git.d464.sh";
                        GITEA__server__START_SSH_SERVER="true";
                        GITEA__server__SSH_PORT="2222";
                        GITEA__server__SSH_LISTEN_PORT="2222";
                        GITEA__server__OFFLINE_MODE="true";
                        GITEA__server__LFS_START_SERVER="true";
                        GITEA__cron__ENABLED="true";
                        GITEA__markup__ENABLED="true";
                        GITEA__webhook__ALLOWED_HOST_LIST="10.0.0.0/24,*.d464.sh";
                        GITEA__webhook__SKIP_TLS_VERIFY="true";
                };
                ports = [
                        "80:3000"
                        "2222:2222"
                ];
        };

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true; # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;
  networking.firewall.allowPing = true;

  # Set your time zone.
  time.timeZone = "Europe/Lisbon";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = { LC_ADDRESS = "pt_PT.UTF-8"; LC_IDENTIFICATION = "pt_PT.UTF-8"; LC_MEASUREMENT =
    "pt_PT.UTF-8"; LC_MONETARY = "pt_PT.UTF-8"; LC_NAME = "pt_PT.UTF-8"; LC_NUMERIC = "pt_PT.UTF-8"; LC_PAPER =
    "pt_PT.UTF-8"; LC_TELEPHONE = "pt_PT.UTF-8"; LC_TIME = "pt_PT.UTF-8";
  };

  # Configure keymap in X11
  services.xserver = { layout = "us"; xkbVariant = "";
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.diogo464 = { isNormalUser = true; description = "diogo464"; extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [];
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Enable automatic login for the user.
  services.getty.autologinUser = "diogo464";

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run: $ nix search wget
  environment.systemPackages = with pkgs; [
        ((import ./dotup.nix) {pkgs = pkgs;})
        git
        neovim
        wget
        curl
        tmux
        zfs
        distrobox
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default. wget
  ];

  # Some programs need SUID wrappers, can be configured further or are started in user sessions. programs.mtr.enable =
  # true; programs.gnupg.agent = {
  #   enable = true; enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon. services.openssh.enable = true;
        services.openssh.enable = true;
        services.openssh.settings.PasswordAuthentication = false;
        users.users."diogo464".openssh.authorizedKeys.keys = [
                "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJYES0m7//Zclc0ffg+NLvseMIG752MzgwVmt5p83Ecs diogo464"
        ];

  # Open ports in the firewall. networking.firewall.allowedTCPPorts = [ ... ]; networking.firewall.allowedUDPPorts = [
  # ... ]; Or disable the firewall altogether. networking.firewall.enable = false;

  # This value determines the NixOS release from which the default settings for stateful data, like file locations and
  # database versions on your system were taken. It‘s perfectly fine and recommended to leave this value at the release
  # version of the first install of this system. Before changing this value read the documentation for this option (e.g.
  # man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?

}
