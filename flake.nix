{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    disko.url = "github:nix-community/disko/latest";
    disko.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    nixpkgs,
    disko,
    ...
  }: {
    nixosConfigurations.factorio-server = nixpkgs.lib.nixosSystem {
      modules = [./configuration.nix disko.nixosModules.disko];
    };
  };
}
