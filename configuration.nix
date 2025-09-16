{ pkgs, ... }: let
  oidcMod = pkgs.fetchFromGitHub {
    owner = "RISE-GmbH";
    repo = "icingaweb2-module-oidc";
    rev = "v0.6.7";
    hash = "sha256-LjzInvfKwXR6Ptt96RAJJGcrA0H1cziR88MqtSpK9Xw=";
  };
in {
  imports = [
    ./hardware-configuration.nix
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

  security.acme = {
    acceptTerms = true;
    defaults.email = "aklimov@icinga.com";
  };

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
      {
        name = "oidc";
        schema = "${oidcMod}/schema/mysql.schema.sql";
      }
    ];
    ensureUsers = [
      {
        name = "icingaweb2";
        ensurePermissions."iw2.*" = "ALL PRIVILEGES";
        ensurePermissions."oidc.*" = "ALL PRIVILEGES";
      }
    ];
  };

  services.icingaweb2 = {
    enable = true;
    virtualHost = "iw2.aklimov.net-dump.de";
    generalConfig.global.config_resource = "iw2";
    modules.monitoring.enable = false;
    authentications.mysql = {
      backend = "db";
      resource = "iw2";
    };
    resources = let
      db = name: {
        type = "db";
        db = "mysql";
        host = "localhost";
        dbname = name;
        username = "icingaweb2";
        charset = "utf8";
      };
    in {
      iw2 = db "iw2";
      oidc = db "oidc";
    };
    roles.adm = {
      users = "icingaadmin";
      permissions = "*";
    };
    modulePackages.oidc = oidcMod;
  };

  services.nginx.virtualHosts."iw2.aklimov.net-dump.de".enableACME = true;
  services.nginx.virtualHosts."iw2.aklimov.net-dump.de".forceSSL = true;

  nixpkgs.overlays = [
    (_: prev: { icingaweb2 = prev.icingaweb2.overrideAttrs (old: {
      patches = [ ./opcache_reset.patch ];

      # https://github.com/NixOS/nixpkgs/pull/380065
      installPhase = old.installPhase + "\ncp -ra schema $out";
    }); })
  ];

  environment.etc."icingaweb2/modules/oidc/config.ini".text = ''
[backend]
resource = "oidc"
'';
}
