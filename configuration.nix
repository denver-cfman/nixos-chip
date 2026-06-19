{ config, lib, pkgs, ... }:

{
  imports =
    [
    ];

  # FIX: Satisfy the fileSystems safety check by defining a root mount placeholder
  fileSystems."/" = {
    device = "/dev/nand"; # Placeholder for C.H.I.P. raw NAND/UBI mount points
    fsType = "ubifs";     # Matches the C.H.I.P. flash infrastructure
  };

  # FIX: Explicitly disable GRUB to satisfy the bootloader configuration safety check
  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.supportedFilesystems = [ "ext4" "ubifs" ];
  
  hardware.enableRedistributableFirmware = true;
  boot.kernelParams = [ "console=ttyS0,115200n8" "earlyprintk" ];

  networking.hostName = "ntc-chip";


  time.timeZone = "America/Denver";

  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  users.users.giezac = {
    isNormalUser = true;
    description = "giezac";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      oh-my-zsh 
    ];
    password = "changeme";
    openssh.authorizedKeys.keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCZawwmpdesq0ZvtXTdPekpjK3OYiPONrKO0no625FqYG8A8fZY++cxjG4my6HgmoaBrZiWvRJTa0WfTfw9Tzx9xt/FKrCB4bk9G33WP+RJNF7AEo3wkGGBLHzxp9bnhzzxdJOQCV67DRDxQNjMiR5S/bkSU+QYPDq+MLLx8mFz8lfzOSThVgDLjOj7lsRAJcrFDawsjZYHjsVBdDfCkjXGPKT7/c90k0BOvOjnOZ4vEn1w2s/Neq0rDTJYDUSmu9SzW/+WkM1rZa4GS5QGFMJVrI1Ow3X8tiUYpAp1oa0MyIpRkpuP39W+I6qaRBW4/+lyJYWsLP09hU7K2wT6OGap forGitHub"
    ];
  };

  users.users.root.openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPmNXnRi9A/6hQL0wxpyti2Qo+Sd8LZt0uLu/hSJ91tH root@R210ii"
  ];

  nixpkgs.config.allowUnfree = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  environment.systemPackages = with pkgs; [
    vim
    wget
    htop
    btop
    iftop
    curl
    git
    fastfetch
    jq
    screen
  ];

  services.openssh.enable = true;
  users.users.root.initialPassword = "nixos";

}
