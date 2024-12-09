{lib, specialArgs, ...}: {
  imports = [
    ./hardware-configuration.nix
  ];

  networking = {
    hostName = "factorio-server";
    useDHCP = true;
  };

  system.stateVersion = "24.05";
  nixpkgs = {
    hostPlatform = "x86_64-linux";
    config.allowUnfree = true;
  };

  services.factorio = {
    enable = true;
    openFirewall = true;
  };

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "yes";
      PasswordAuthentication = false;
    };
  };

  users.users.root = {
    openssh.authorizedKeys.keys = lib.optional (specialArgs ? ssh_key) specialArgs.ssh_key;
  };
}
