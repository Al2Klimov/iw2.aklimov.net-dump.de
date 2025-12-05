{ config, pkgs, ... }: {
  users.groups.mergeconflict-tgbot = { };

  users.users.mergeconflict-tgbot = {
    isSystemUser = true;
    group = "mergeconflict-tgbot";
  };

  age.secrets.MERGECONFLICT_TGBOT_TGTOKEN = {
    file = ./MERGECONFLICT_TGBOT_TGTOKEN.age;
    owner = "mergeconflict-tgbot";
  };

  systemd.services.mergeconflict-tgbot = {
    requires = [ "network-online.target" ];
    serviceConfig = {
      StateDirectory = "mergeconflict-tgbot";
      StateDirectoryMode = "0750";
      User = "mergeconflict-tgbot";
      WorkingDirectory = "/var/lib/mergeconflict-tgbot";
      ExecStartPre = "${pkgs.coreutils}/bin/sleep 69";
      ExecStart = with pkgs; writeShellScript "" ''
export MERGECONFLICT_TGBOT_TGTOKEN="$(< ${config.age.secrets.MERGECONFLICT_TGBOT_TGTOKEN.path})"
exec ${rustPlatform.buildRustPackage {
  name = "mergeconflict-tgbot";
  src = fetchFromGitHub {
    owner = "Al2Klimov";
    repo = "mergeconflict-tgbot";
    rev = "d8597c55ebd8a0b4b2e813f305b257f5753bdd34";
    hash = "sha256-4hMUhj6T89CUzGkGprsqVfX8IlsET6FCwvAQLlm4hNI=";
  };
  cargoHash = "sha256-1Vnj52lTbk2m2fihlj0sCpkf0pBxhMt4kuT2tBJaBqo=";
  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ openssl ];
}}/bin/mergeconflict-tgbot
'';
    };
    wantedBy = [ "multi-user.target" ];
  };
}
