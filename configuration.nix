{ ... }: {
  imports = [
    ./hardware-configuration.nix
    ./iw2.nix
    ./mergeconflict-tgbot.nix

    "${builtins.fetchTarball {
      url = "https://github.com/ryantm/agenix/archive/564595d0ad4be7277e07fa63b5a991b3c645655d.tar.gz";
      sha256 = "01dhrghwa7zw93cybvx4gnrskqk97b004nfxgsys0736823956la";
    }}/modules/age.nix"
  ];

  networking.hostName = "aklimov-nixos";
  system.stateVersion = "23.11";
  boot.tmp.cleanOnBoot = true;

  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 80 443 ];

  system.autoUpgrade.enable = true;
  system.autoUpgrade.allowReboot = true;
  nix.gc.automatic = true;
  nix.gc.options = "--delete-older-than 7d";

  services.openssh.enable = true;
  users.users.root.openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBIroHYGSRaRNFxlK90SS0aHwWjEME30pK5J1N/V1w6a" ];
}
