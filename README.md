# nixos-chip

## Build
```bash
nix build .#nixosConfigurations.chip.config.system.build.tarball
```
Building and flashing NixOS onto an original C.H.I.P. is an advanced engineering challenge because the board features a 32-bit ARMv7 architecture (Allwinner R8) and boots exclusively from an onboard MLC NAND flash module, whereas standard ARM NixOS builds target modern 64-bit ARM (AArch64) MicroSD/eMMC devices. [1, 2, 3] 
To pull this off, you must cross-compile a custom ARMv7 NixOS system image containing the C.H.I.P. device tree files, compile U-Boot, and bootstrap the installation using a Linux host machine over a USB-to-serial connection. [4] 
------------------------------
## Step 1: Prepare the Cross-Compilation Environment [5] 
Because the C.H.I.P. only has 512MB of RAM, compiling NixOS on the board itself is impossible. You must build the system on a faster x86_64 or AArch64 host machine running Nix. [1, 3, 6, 7, 8] 

   1. Ensure Nix is installed on your development machine.
   2. Create a clean workspace and define a custom flake.nix that targets 32-bit ARM (armv7l-linux) and incorporates the Allwinner/sunxi U-Boot requirements: [9, 10, 11] 

------------------------------
## Step 2: Build U-Boot for the C.H.I.P.
The C.H.I.P. requires a highly customized version of U-Boot configured for its specific NAND timings. Standard NixOS image builders will lack the correct MBR/UBI formatting layout. [12] 

   1. Download the community-maintained [Joel Guittet C.H.I.P. Tools GitHub](https://github.com/joelguittet/chip-hardware) repository onto your flashing machine. This repository handles the low-level FEL communication required by the Allwinner processor.
   2. Install the necessary system dependencies on your host (such as sunxi-tools, fastboot, and dfu-util). [13] 

------------------------------
## Step 3: Flash the System in FEL Mode
Because the C.H.I.P. does not have a MicroSD slot, you cannot simply dd an image file. You must flash the raw partition directly to the board's internal storage: [14, 15] 

   1. Jumper FEL Mode: Connect a physical jumper wire between the FEL pin and GND on the C.H.I.P. header rails.
   2. Connect to Host: Use a high-quality Micro-USB cable to plug the C.H.I.P. into your flashing host machine.
   3. Execute Flashing Tools: Use the helper scripts within chip-tools to target the flash space:
   
   sudo ./chip-fel-flash.sh /path/to/your/built/u-boot.bin /path/to/nixos-tarball.tar.gz
   
   Note: This process formats the internal flash into an MTD/UBI partition structure suited for Raw MLC NAND storage. [13, 16] 

------------------------------
## Step 4: Monitor Initial Boot
Once flashing completes, remove the FEL jumper wire. To monitor NixOS booting up for the first time: [16] 

   1. Connect a 3.3v USB-to-UART Serial Cable to the C.H.I.P.’s GND, TX (UART1_TX), and RX (UART1_RX) header pins.
   2. Open a terminal emulator on your host machine matching the kernel parameters defined in your Nix flake:
   
   screen /dev/ttyUSB0 115200
   
   3. Power on the board. You will see U-Boot execute, initialize the kernel, and drop into the NixOS multi-user target prompt. [1, 4, 17, 18] 

If you encounter syntax blocks during cross-compilation, let me know:

* 
* What CPU Architecture your main development host machine runs (Intel/AMD or Apple Silicon)?
* Do you intend to run the system headless over Wi-Fi/SSH, or are you using the Pocket C.H.I.P. keyboard/screen shell? [2] 
* 


[1] [https://www.youtube.com](https://www.youtube.com/watch?v=9W6znVpxn1c)
[2] [https://www.youtube.com](https://www.youtube.com/watch?v=9QphSElOPLA&t=11)
[3] [https://www.cnx-software.com](https://www.cnx-software.com/2015/05/08/chip-is-a-9-linux-development-board-powered-by-allwinner-r8-crowdfunding/)
[4] [https://github.com](https://github.com/dwelch67/ntc_chip_examples)
[5] [https://www.linkedin.com](https://www.linkedin.com/pulse/understanding-make-oldconfig-prepare-arm64-david-zhu-uy3ac)
[6] [https://www.linux-magazine.com](http://www.linux-magazine.com/Online/Features/Exploring-the-Tiny-9-C.H.I.P.-Computer)
[7] [https://nixos-and-flakes.thiscute.world](https://nixos-and-flakes.thiscute.world/development/cross-platform-compilation)
[8] [https://www.reddit.com](https://www.reddit.com/r/NixOS/comments/1fe18s7/why_useful_is_cross_compilation_for_nixpkgs/)
[9] [https://github.com](https://github.com/katyo/nixos-arm)
[10] [https://aws.plainenglish.io](https://aws.plainenglish.io/its-alive-bootstrapping-a-declarative-nixos-homelab-part-1-79d11e917de2)
[11] [https://discourse.nixos.org](https://discourse.nixos.org/t/using-nix-develop-opens-bash-instead-of-zsh/25075)
[12] [https://nixos.wiki](https://nixos.wiki/wiki/NixOS_on_ARM/Allwinner_GPT_Installation)
[13] [https://linux-sunxi.org](https://linux-sunxi.org/NextThingCo_CHIP)
[14] [https://www.reddit.com](https://www.reddit.com/r/NixOS/comments/160t87r/how_to_install_nixos_onto_a_flash_drive/)
[15] [https://www.youtube.com](https://www.youtube.com/watch?v=XkfBWAJ7kbI&t=6)
[16] [https://docs.getchip.cc](https://docs.getchip.cc/chip_pro_devkit)
[17] [https://www.genuinemodules.com](https://www.genuinemodules.com/how-to-install-cisco-usb-console-driver_a370)
[18] [https://corstone1000.docs.arm.com](https://corstone1000.docs.arm.com/en/latest/user-guide.html)

---

---
### check this flake
```
nix flake check -v -L --no-build --no-write-lock-file --all-systems github:denver-cfman/nixos-chip?ref=main
```

### show this flake
```
nix flake show --all-systems --json github:denver-cfman/nixos-chip?ref=main | jq '.'
```

### remote install via nixos-anywhere
```bash
nix run github:nix-community/nixos-anywhere -- --flake 'github:denver-cfman/nixos-chip?ref=tinker#pine64' --target-host nixos@10.0.85.186
```

### remote update nix (nixos-rebuild) on cluster head
#### nixos-rebuild
```
sudo nixos-rebuild switch --impure --refresh --flake github:denver-cfman/nixos-chip?ref=tinker#pine64 --no-write-lock-file
```
#### deploy-rs
```
K3S_TOKEN=thisisjustatest nix run github:serokell/deploy-rs github:denver-cfman/nixos-chip?ref=main#pine64 -- -s -d --ssh-user giezac --hostname 10.0.81.99
```
#### build tarball for flashing
```
nix build --impure --refresh --rebuild --no-update-lock-file -L -v github:denver-cfman/nixos-chip?ref=flake-up#nixosConfigurations.chip.config.system.build.tarball
```

#### Test Compile of a single package
```
nix build github:NixOS/nixpkgs/e4f449ab51a283676d3b520c3dbaa3eafa5025b4#pkgsCross.aarch64-multiplatform.screen
```
