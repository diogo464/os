# Edit this configuration file to define what should be installed on your system.  Help is available in the
# configuration.nix(5) man page and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../../modules/basic.nix
      ../../modules/user.nix
    ];

  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/vda";
  boot.loader.grub.useOSProber = true;

  virtualisation.containerd.enable = true;
  virtualisation.oci-containers.containers.gitea = {
    image = "docker.io/gitea/gitea:1.21.3";
    environment = {
      GITEA__database__DBTYPE = "sqlite3";
      GITEA__repository__ENABLE_PUSH_CREATE_USER = "true";
      GITEA__repository__ENABLE_PUSH_CREATE_ORG = "true";
      GITEA__repository__DEFAULT_BRANCH = "main";
      GITEA__repository__DEFAULT_REPO_UNITS = "repo.code,repo.releases,repo.issues,repo.pulls,repo.wiki,repo.projects,repo.packages,repo.actions";
      GITEA__repository__DEFAULT_PRIVATE = "public";
      GITEA__repository__DEFAULT_PUSH_CREATE_PRIVATE = "false";
      GITEA__ui_0x2E_user__REPO_PAGING_NUM = "25";
      GITEA__server__PROTOCOL = "http";
      GITEA__server__HTTP_PORT = "3000";
      GITEA__server__DOMAIN = "git.d464.sh";
      GITEA__server__ROOT_URL = "http://git.d464.sh";
      GITEA__server__START_SSH_SERVER = "true";
      GITEA__server__SSH_PORT = "2222";
      GITEA__server__SSH_LISTEN_PORT = "2222";
      GITEA__server__OFFLINE_MODE = "true";
      GITEA__server__LFS_START_SERVER = "true";
      GITEA__cron__ENABLED = "true";
      GITEA__markup__ENABLED = "true";
      GITEA__webhook__ALLOWED_HOST_LIST = "10.0.0.0/24,*.d464.sh";
      GITEA__webhook__SKIP_TLS_VERIFY = "true";
    };
    ports = [
      "80:3000"
      "2222:2222"
    ];
  };

  # Define your hostname.
  networking.hostName = "nas";

  # Enable automatic login for the user.
  services.getty.autologinUser = "diogo464";

  # List packages installed in system profile. To search, run: $ nix search wget
  environment.systemPackages = with pkgs; [
  ];

  # Some programs need SUID wrappers, can be configured further or are started in user sessions. programs.mtr.enable =
  # true; programs.gnupg.agent = {
  #   enable = true; enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Open ports in the firewall. networking.firewall.allowedTCPPorts = [ ... ]; networking.firewall.allowedUDPPorts = [
  # ... ]; Or disable the firewall altogether. networking.firewall.enable = false;

  # This value determines the NixOS release from which the default settings for stateful data, like file locations and
  # database versions on your system were taken. It‘s perfectly fine and recommended to leave this value at the release
  # version of the first install of this system. Before changing this value read the documentation for this option (e.g.
  # man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}

