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
    rev = "1ec17181910782d15ee6a19ff5c52ba04c451eff";
    hash = "sha256-o/O+5iUi+U3sRNoYQbq8cOhv7ms/1VwUYUWIy9BbqNI=";
  };
  cargoHash = "sha256-D1KhzOCb3bpoggoxHhakjtFfPodj7I2ElylBO+xq64U=";
  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ openssl ];
}}/bin/mergeconflict-tgbot
'';
    };
    wantedBy = [ "multi-user.target" ];
  };
}
