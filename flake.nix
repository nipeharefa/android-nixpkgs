{
  description = "Packages for Android development";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }@inputs:
    let
      inherit (nixpkgs.lib) genAttrs;
      systems = [ "x86_64-linux" ];

    in {
      hmModules.android-sdk = import ./hm-module.nix;

      # TODO Need to flatten the attrset in order to provide 'packages'.
      legacyPackages = genAttrs systems (system:
        let
          pkgs = import nixpkgs { inherit system; };
          androidpkgs = import ./default.nix { inherit pkgs; };
        in
          # Just canary packages for now. Usually this is a superset of
          # the more stable channels, with the exception of the emulator.
          androidpkgs.packages.canary
      );

      overlay = final: prev: {
        androidSdkPackages = (import ./default.nix { pkgs = final; }).packages.canary;
      };

      packages = genAttrs systems (system:
        let
          pkgs = import nixpkgs { inherit system; };
        in {
          sample = import ./sample.nix { inherit pkgs; };
        });
    };
}
