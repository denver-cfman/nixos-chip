{
  description = "NixOS for NextThing Co. C.H.I.P.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }: {

    # 1. Target configuration for LIVE maintenance (nixos-rebuild)
    # This evaluates natively when run on the device.
    nixosConfigurations.chip = nixpkgs.lib.nixosSystem {
      modules = [
        ./configuration.nix # Inline logic moved here for readability, or keep inline
        ({ ... }: {
          # On-device native building
          nixpkgs.hostPlatform = "armv7l-linux";
        })
      ];
    };

    # 2. Cross-compiled configuration specifically for host-driven tarball builds
    # This forces the build matrix to handle the x86_64 -> armv7l cross-compilation pipeline.
    packages.x86_64-linux.default = 
      let
        crossPkgs = nixpkgs.lib.nixosSystem {
          modules = [
            ./configuration.nix
            ({ config, pkgs, ... }: {
              nixpkgs.localSystem.system = "x86_64-linux";
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
            })
          ];
        };
      in
        crossPkgs.config.system.build.tarball;
  };
}
