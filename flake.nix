{
  description = "NixOS for NextThing Co. C.H.I.P.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }: 
    let
      system = "x86_64-linux"; # Your host development machine
    in {
      packages.${system}.default = self.nixosConfigurations.chip.config.system.build.tarball;

      nixosConfigurations.chip = nixpkgs.lib.nixosSystem {
        modules = [
          ({ config, pkgs, ... }: {
            nixpkgs.localSystem.system = system;
            nixpkgs.crossSystem.system = "armv7l-linux";

            # Direct generation of the root filesystem tarball layout
            system.build.tarball = pkgs.callPackage "${nixpkgs}/nixos/lib/make-system-tarball.nix" {
              fileName = "nixos-chip-rootfs";
              compressCommand = "${pkgs.gzip}/bin/gzip -c"; 
              storeContents = [ { object = config.system.build.toplevel; symlink = "none"; } ];
              contents = [
                { source = config.system.build.toplevel + "/init"; target = "/sbin/init"; }
              ];
            };

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
            services.openssh.enable = true;
            users.users.root.initialPassword = "nixos";
          })
        ];
      };
    };
}
