{
  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    };
    flake-utils = {
      url = "github:numtide/flake-utils";
    };
    twist = {
      url = "github:emacs-twist/twist.nix";
    };
    org-babel = {
      url = "github:emacs-twist/org-babel";
    };

    melpa = {
      url = "github:melpa/melpa";
      flake = false;
    };
    gnu-elpa = {
      url = "git+https://git.savannah.gnu.org/git/emacs/elpa.git?ref=main";
      flake = false;
    };
    nongnu = {
      url = "git+https://git.savannah.gnu.org/git/emacs/nongnu.git?ref=main";
      flake = false;
    };
    epkgs = {
      url = "github:emacsmirror/epkgs";
      flake = false;
    };
    emacs = {
      url = "github:emacs-mirror/emacs";
      flake = false;
    };
  };

  outputs = {
    self,
    flake-utils,
    nixpkgs,
    ...
  } @ inputs:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            inputs.twist.overlays.default
            inputs.org-babel.overlays.default
          ];
        };

        emacs = pkgs.emacsTwist {
          emacsPackage = pkgs.emacs-macport;

          registries = import ./registries.nix inputs;
          lockDir = ./lock;
          initFiles = [
            (pkgs.tangleOrgBabelFile "init.el" ./init.org {})
          ];

          extraPackages = ["leaf"];
        };
      in rec {
        packages = flake-utils.lib.flattenTree {
          inherit emacs;
        };
        apps = emacs.makeApps {
          lockDirName = "lock";
        };
        defaultPackage = packages.emacs;
      }
    );
}
