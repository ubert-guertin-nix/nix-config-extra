{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix = {
      url = "github:danth/stylix/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      stylix,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      username = "userbox";
      gitEmail = "${username}@nixos.org";
      gitName = username;


      sharedArgs = {
        inherit
          inputs
          username
          gitName
          gitEmail
          ;
      };
    in
    {
      nixosConfigurations.${username} = nixpkgs.lib.nixosSystem {
        inherit system;

        specialArgs = sharedArgs;

        modules = [
          ./configuration.nix
          stylix.nixosModules.stylix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = sharedArgs;
            home-manager.users.${username} = ./home-config.nix;
          }
        ];
      };
    };
}
