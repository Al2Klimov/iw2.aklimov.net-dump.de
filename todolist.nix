{ config, pkgs, ... }: {
  age.secrets.todolist-config-ini = {
    file = ./todolist/config.ini.age;
    owner = "icingaweb2";
  };

  age.secrets.todolist-providers-ini = {
    file = ./todolist/providers.ini.age;
    owner = "icingaweb2";
  };

  environment.etc."icingaweb2/modules/todolist/config.ini".source = config.age.secrets.todolist-config-ini.path;
  environment.etc."icingaweb2/modules/todolist/providers.ini".source = config.age.secrets.todolist-providers-ini.path;

  systemd.services.icinga-todolist = with pkgs; {
    requires = [ "network-online.target" ];

    # https://github.com/NixOS/nixpkgs/issues/380864
    environment.ICINGAWEB_LIBDIR = stdenvNoCC.mkDerivation {
      name = "icinga-php";
      phases = [ "installPhase" ];
      installPhase = ''
mkdir -p $out
ln -s ${icingaweb2-ipl} $out/ipl
ln -s ${icingaweb2-thirdparty} $out/vendor
'';
    };

    serviceConfig = {
      # Trigger restart on change
      ExecStartPre = "${coreutils}/bin/ls ${config.age.secrets.todolist-config-ini.path} ${config.age.secrets.todolist-providers-ini.path}";

      ExecStart = "${icingaweb2}/bin/icingacli todolist daemon run";
      Restart = "on-failure";
      RestartSec = "5";
      User = "icingaweb2";
      WorkingDirectory = "/tmp";
    };
    wantedBy = [ "multi-user.target" ];
  };
}
