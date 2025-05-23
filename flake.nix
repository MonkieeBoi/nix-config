{
    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    };

    outputs = { self, nixpkgs }:
    let
        system = "x86_64-linux";
        pkgs = import nixpkgs {
            inherit system;

            config = {
                allowUnfree = true;
            };
        };

    in
    {
        nixosConfigurations = {
            nixbtw = nixpkgs.lib.nixosSystem {
                specialArgs = { inherit system; };

                modules = [
                    ./configuration.nix
                ];
            };
        };
    };
}
