let
  pkgs = import ./nixpkgs.nix {};

in pkgs.haskellPackages.shellFor {
  packages = p: [p.amazonka-servant-streaming];
  buildInputs = [
    pkgs.haskellPackages.cabal-install
    pkgs.haskellPackages.ghc
    pkgs.haskellPackages.ghcid
  ];
}
