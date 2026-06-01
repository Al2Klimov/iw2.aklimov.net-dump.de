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
    rev = "fcea83607b1417a569e7f792fd2fd7e78d2bae07";
    hash = "sha256-XBOe3/ZotTbUUomQ43CewPD5sg5w9yTofEbFFn3iT78=";
  };
  cargoHash = "sha256-Hp3lDF4tpL15Ct3ocEw0up3xZp3TTGevXvxSvL4mSgg=";
  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ openssl ];
}}/bin/mergeconflict-tgbot
'';
    };
    wantedBy = [ "multi-user.target" ];
  };
}
