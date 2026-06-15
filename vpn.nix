{ config, ... }:
{
  # un/tiQu6IRJe5q48D6/8WHjoO0bpv/o+HiQO4RgYgBE=
  age.secrets.wg-privkey.file = ./wg-privkey.age;

  networking.wireguard = {
    enable = true;
    interfaces.wg0 = {
      listenPort = 443;
      privateKeyFile = config.age.secrets.wg-privkey.path;
      ips = [ "192.168.69.254/24" ];
      peers = [
        { # WS
          publicKey = "7OXk1+FDoBMfQScE1Z6Ro9syyUhwuk9jYZSGOTTONXA=";
          allowedIPs = [ "192.168.69.42/32" ];
        }
      ];
    };
  };

  networking.nat = {
    enable = true;
    externalInterface = "enp3s0";
    internalInterfaces = [ "wg0" ];
  };
}
