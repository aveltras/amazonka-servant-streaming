let
  githubTarball = owner: repo: rev:
    builtins.fetchTarball { url = "https://github.com/${owner}/${repo}/archive/${rev}.tar.gz"; };

  nixpkgsSrc = commit:
    githubTarball "NixOS" "nixpkgs" commit;

  localOverlays = [
    # make ghc8107 the default package set for haskell
    (self: super: {
      # to see the versions of the packages currently in use
      # visit https://raw.githubusercontent.com/NixOS/nixpkgs/${NIXPKGS_COMMIT_HERE}/pkgs/development/haskell-modules/hackage-packages.nix
      haskellPackages = super.haskell.packages.ghc8107.override {
        overrides = hself: hsuper:
          let
            amazonkaSrc = githubTarball "brendanhay" "amazonka" "2.0.0-rc1";
          in {
            amazonka = self.haskell.lib.dontCheck (hsuper.callCabal2nix "amazonka" "${amazonkaSrc}/lib/amazonka" {});
            amazonka-core = self.haskell.lib.dontCheck (hsuper.callCabal2nix "amazonka-core" "${amazonkaSrc}/lib/amazonka-core" {});
            amazonka-s3 = self.haskell.lib.dontCheck (hsuper.callCabal2nix "amazonka-s3" "${amazonkaSrc}/lib/services/amazonka-s3" {});
            amazonka-sts = self.haskell.lib.dontCheck (hsuper.callCabal2nix "amazonka-sts" "${amazonkaSrc}/lib/services/amazonka-sts" {});
            amazonka-test = self.haskell.lib.dontCheck (hsuper.callCabal2nix "amazonka-test" "${amazonkaSrc}/lib/amazonka-test" {});
            amazonka-servant-streaming = hsuper.callCabal2nix "amazonka-servant-streaming" ./. {};
          };
      };
    })
  ];

in args@{ overlays ? [], commit ? "8bd55a6a5ab05942af769c2aa2494044bff7f625", ... }:
  import (nixpkgsSrc commit) (args // {
    overlays = localOverlays ++ overlays;
  })
