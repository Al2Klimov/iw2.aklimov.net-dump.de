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
    rev = "e65b39c1c7661ae509e4f6c37971144bf5ca4e98";
    hash = "sha256-c+ESHwZj4XHJCp3WYfl5eKaeQoIo43Uup4iCvVTZ2UU=";
  };
  cargoHash = "sha256-B6g4/pp3M0ymSI8f3hNh1bBTY4sya7X+RTeL88hgoNQ=";
  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ openssl ];
}}/bin/mergeconflict-tgbot
'';
    };
    wantedBy = [ "multi-user.target" ];
  };
}
