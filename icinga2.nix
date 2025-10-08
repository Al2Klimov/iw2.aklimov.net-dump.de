{ config, pkgs, ... }: {
  users.groups.icinga2 = { };

  users.users.icinga2 = {
    isSystemUser = true;
    group = "icinga2";
  };

  age.secrets.ENTG_TOKEN = {
    file = ./ENTG_TOKEN.age;
    owner = "icinga2";
  };

  systemd.services.icinga2 = with pkgs; {
    requires = [ "network-online.target" ];
    serviceConfig = {
      ExecStart = "+${icinga2}/bin/icinga2 daemon --close-stdio -c ${./icinga2.conf} -DPluginDir=${monitoring-plugins}/bin";
      Type = "notify";
      NotifyAccess = "all";
      KillMode = "mixed";

      StateDirectory = "icinga2";
      StateDirectoryMode = "0750";
      RuntimeDirectory = "icinga2";
      RuntimeDirectoryMode = "0750";
      CacheDirectory = "icinga2";
      CacheDirectoryMode = "0750";
      User = "icinga2";
    };
    wantedBy = [ "multi-user.target" ];
    path = [
      systemd
      (rustPlatform.buildRustPackage {
        name = "check_rungrep";
        src = fetchFromGitHub {
          owner = "Al2Klimov";
          repo = "check_rungrep";
          rev = "v0.1.0";
          hash = "sha256-rjCmEcIDKPvzOl7+LyYWGcfhDOorXrGw+3OL8v561hg=";
        };
        cargoHash = "sha256-jw58qtovME+/gzkcIyx4xlb1gmqDwt8/UGQePSXbGrs=";
      })
      (writeShellScriptBin "env_notify_telegram" ''
export ENTG_TOKEN="$(< ${config.age.secrets.ENTG_TOKEN.path})"
exec ${rustPlatform.buildRustPackage {
  name = "env_notify_telegram";
  src = fetchFromGitHub {
    owner = "Al2Klimov";
    repo = "env_notify_telegram";
    rev = "v0.1.1";
    hash = "sha256-CUFBPDAJjPwKM3BigxlPIzE86XIVGw+wOVs8i1hQPEo=";
  };
  cargoHash = "sha256-YIbIJYSeDGTt16/+3d80L/QQ3lER2igGINcBwACZbUU=";
}}/bin/env_notify_telegram
''
      )
];
  };
}
