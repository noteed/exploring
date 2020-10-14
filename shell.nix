{ pkgs ? import <nixpkgs> {} }:
  pkgs.mkShell {
    buildInputs = [
      pkgs.ghcid
      (pkgs.haskellPackages.ghcWithPackages (hpkgs: [
      ]))
      pkgs.sqlite
    ];
}
