{pkgs, ...}: {
  imports = [
    ./hardware-configuration.nix
  ];
  networking.hostName = "factorio-hackathon";
  nixpkgs.config.allowUnfree = true;

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "yes";
      PasswordAuthentication = false;
    };
  };
  users.users.root = {
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDci4wJghnRRSqQuX1z2xeaUR+p/muKzac0jw0mgpXE2T/3iVlMJJ3UXJ+tIbySP6ezt0GVmzejNOvUarPAm0tOcW6W0Ejys2Tj+HBRU19rcnUtf4vsKk8r5PW5MnwS8DqZonP5eEbhW2OrX5ZsVyDT+Bqrf39p3kOyWYLXT2wA7y928g8FcXOZjwjTaWGWtA+BxAvbJgXhU9cl/y45kF69rfmc3uOQmeXpKNyOlTk6ipSrOfJkcHgNFFeLnxhJ7rYxpoXnxbObGhaNqn7gc5mt+ek+fwFzZ8j6QSKFsPr0NzwTFG80IbyiyrnC/MeRNh7SQFPAESIEP8LK3PoNx2l1M+MjCQXsb4oIG2oYYMRa2yx8qZ3npUOzMYOkJFY1uI/UEE/j/PlQSzMHfpmWus4o2sijfr8OmVPGeoU/UnVPyINqHhyAd1d3Iji3y3LMVemHtp5wVcuswABC7IRVVKZYrMCXMiycY5n00ch6XTaXBwCY00y8B3Mzkd7Ofq98YHc= gabriel@gsfontes.com"
    ];
  };

  services.factorio = {
    enable = true;
    openFirewall = true;
    package = pkgs.factorio-headless.overrideAttrs rec {
      version = "2.0.12";
      src = pkgs.fetchurl {
        name = "factorio_headless_x64-${version}.tar.xz";
        url = "https://factorio.com/get-download/${version}/headless/linux64";
        sha256 = "sha256-0vgg5eJ6ZEFO0TUixNsByCs8YyPGOArgqnXbT5RIjTE=";
      };
    };
  };
  system.stateVersion = "24.05";
}
