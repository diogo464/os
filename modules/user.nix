{ pkgs, ... }:
{
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.diogo464 = {
    isNormalUser = true;
    description = "diogo464";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [ ];
  };

  users.users."diogo464".openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJYES0m7//Zclc0ffg+NLvseMIG752MzgwVmt5p83Ecs diogo464"
  ];
}

