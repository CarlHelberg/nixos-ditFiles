{ pkgs, ... }:

let
  intellijWrapper = pkgs.writeShellScriptBin "intellij-idea-ultimate" ''
    export LD_LIBRARY_PATH=${pkgs.libGL}/lib:${pkgs.libGLU}/lib:${pkgs.xorg.libX11}/lib:${pkgs.xorg.libXrender}/lib:${pkgs.xorg.libXext}/lib:${pkgs.xorg.libXtst}/lib:${pkgs.xorg.libXi}/lib:$LD_LIBRARY_PATH
    ${pkgs.jetbrains.idea-ultimate}/bin/idea-ultimate "$@"
  '';
in
{
  environment.systemPackages = [ intellijWrapper ];
} 