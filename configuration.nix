{ ... }: {
  imports = [
    ./hardware-configuration.nix
  ];

  networking.hostName = "aklimov-nixos";
  system.stateVersion = "23.11";
  boot.tmp.cleanOnBoot = true;
  networking.firewall.enable = true;

  services.openssh.enable = true;
  users.users.root.openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBIroHYGSRaRNFxlK90SS0aHwWjEME30pK5J1N/V1w6a" ];
}
