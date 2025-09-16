{ pkgs, ... }: {
  imports = [
    ./hardware-configuration.nix
  ];

  networking.hostName = "aklimov-nixos";
  system.stateVersion = "23.11";
  boot.tmp.cleanOnBoot = true;

  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 80 ];

  system.autoUpgrade.enable = true;
  system.autoUpgrade.allowReboot = true;
  nix.gc.automatic = true;
  nix.gc.options = "--delete-older-than 7d";

  services.openssh.enable = true;
  users.users.root.openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBIroHYGSRaRNFxlK90SS0aHwWjEME30pK5J1N/V1w6a" ];

  services.mysql = with pkgs; {
    enable = true;
    package = mariadb;
    initialDatabases = [
      {
        name = "iw2";
        schema = writeText "schema" ((builtins.readFile "${icingaweb2.src}/schema/mysql.schema.sql") + ''
INSERT INTO icingaweb_user VALUES ('icingaadmin', 1, '$2y$05$bZFogtHKoarFf3QMSLs8.eBfgDdSBA/ULt0SEQOEIkcg0/gvs9MuW', NOW(), NOW());
'');
      }
    ];
    ensureUsers = [
      {
        name = "icingaweb2";
        ensurePermissions."iw2.*" = "ALL PRIVILEGES";
      }
    ];
  };

  services.icingaweb2 = {
    enable = true;
    generalConfig.global.config_resource = "iw2";
    modules.monitoring.enable = false;
    authentications.mysql = {
      backend = "db";
      resource = "iw2";
    };
    resources.iw2 = {
      type = "db";
      db = "mysql";
      host = "localhost";
      dbname = "iw2";
      username = "icingaweb2";
      charset = "utf8";
    };
    roles.adm = {
      users = "icingaadmin";
      permissions = "*";
    };
  };
}
