{ pkgs, ... }: let
  oidcMod = pkgs.fetchFromGitHub {
    owner = "RISE-GmbH";
    repo = "icingaweb2-module-oidc";
    rev = "v0.7.3";
    hash = "sha256-tD1YPOobHqcuN6ntedHdidRHmjpBr4A4LJyhHCqfu3E=";
  };
in {
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

  services.redis.enable = true;

  services.icingaweb2 = {
    enable = true;
    virtualHost = "iw2.aklimov.net-dump.de";
    generalConfig.global.config_resource = "iw2";
    modules.monitoring.enable = false;
    authentications = {
      mysql = {
        backend = "db";
        resource = "iw2";
      };
      GitLab = {
        backend = "oidc";
        provider_id = "1";
        disabled = "1";
      };
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
    roles = {
      adm = {
        users = "icingaadmin,Alexander A. Klimov";
        permissions = "*";
      };
      game = {
        users = "*";
        permissions = "module/fourcolors,module/whoarewe";
      };
    };
    modulePackages = {
      oidc = oidcMod;
      fourcolors = pkgs.fetchFromGitHub {
        owner = "Al2Klimov";
        repo = "icingaweb2-module-fourcolors";
        rev = "8802dee00be542840e3e09c52501c0f4cfb61371";
        hash = "sha256-WxcFVyTMPP4c45Om5PzALEpB88+XUQKeTMj+vVUXwvA=";
      };
      whoarewe = pkgs.fetchFromGitHub {
        owner = "Al2Klimov";
        repo = "icingaweb2-module-whoarewe";
        rev = "06aaf814e8b32ab48e9fc9cb8bd3dbe2022d368e";
        hash = "sha256-gf703IRQlSsHXcqAGDQMATknCWfhMerg789J08ZSqb0=";
      };
    };
  };

  services.nginx.virtualHosts."iw2.aklimov.net-dump.de".enableACME = true;
  services.nginx.virtualHosts."iw2.aklimov.net-dump.de".forceSSL = true;

  nixpkgs.overlays = [
    (_: prev: { icingaweb2 = prev.icingaweb2.overrideAttrs (_: {
      patches = [
        ./opcache_reset.patch

        # https://github.com/Icinga/icingaweb2/issues/5427
        ./migrations-db-no-pw.patch
      ];
    }); })
  ];

  environment.etc."icingaweb2/modules/oidc/config.ini".text = ''
[backend]
resource = "oidc"
'';

  environment.etc."icingaweb2/modules/oidc/files/gitlab.png".source = "${pkgs.stdenvNoCC.mkDerivation {
    name = "gitlab_logo";
    phases = [ "installPhase" ];
    installPhase = ''
mkdir -p $out
cp ${pkgs.gitlab.src}/app/assets/images/gitlab_logo.png $out/
'';
}}/gitlab_logo.png";
}
