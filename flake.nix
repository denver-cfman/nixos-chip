# flake.nix
{
  description = "NixOS for NextThing Co. C.H.I.P.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }: {
    nixosConfigurations.chip = nixpkgs.lib.nixosSystem {
      # Target cross-compilation to ARMv7l
      modules = [
        ({ config, pkgs, ... }: {
          nixpkgs.localSystem.system = "x86_64-linux"; # Your host system
          nixpkgs.crossSystem.system = "armv7l-linux";

          boot.kernelPackages = pkgs.linuxPackages_latest;
          boot.supportedFilesystems = [ "ext4" "ubifs" ];
          
          # Target Allwinner R8/A13 configuration
          boot.loader.generic-extlinux-compatible.enable = true;
          
          # Include necessary firmware for the RTL8723BS Wi-Fi / Bluetooth chip
          hardware.enableRedistributableFirmware = true;

          # Headless serial console setup
          boot.kernelParams = [ "console=ttyS0,115200n8" "earlyprintk" ];

          networking.hostName = "ntc-chip";
          
          # Configure basic user and SSH access
          services.openssh.enable = true;
          users.users.root.initialPassword = "nixos";
        })
      ];
    };
  };
}
