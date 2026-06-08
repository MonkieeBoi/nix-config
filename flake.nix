{
    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
        nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.11";
    };

    outputs = { self, nixpkgs , nixpkgs-stable}:
    let
        system = "x86_64-linux";
    in
    {
        nixosConfigurations = {
            nixbtw = nixpkgs.lib.nixosSystem {
                specialArgs = { inherit system nixpkgs-stable; };

                modules = [
                    ./configuration.nix
                ];
            };
        };
    };
}
