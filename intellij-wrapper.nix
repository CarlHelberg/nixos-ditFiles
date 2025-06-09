{ pkgs, ... }:

let
  intellijWrapper = pkgs.writeShellScriptBin "intellij-idea-ultimate" ''
    # Set up environment for IntelliJ and its plugins
    export LD_LIBRARY_PATH=${pkgs.libGL}/lib:${pkgs.libGLU}/lib:${pkgs.mesa.drivers}/lib:${pkgs.xorg.libX11}/lib:${pkgs.xorg.libXrender}/lib:${pkgs.xorg.libXext}/lib:${pkgs.xorg.libXtst}/lib:${pkgs.xorg.libXi}/lib:$LD_LIBRARY_PATH
    
    # Add LD_PRELOAD to ensure libGL.so.1 is found by Skiko
    export LD_PRELOAD=${pkgs.libGL}/lib/libGL.so.1:${pkgs.libGLU}/lib/libGLU.so.1:$LD_PRELOAD
    
    # Make sure Java can find the graphics libraries
    export _JAVA_OPTIONS="-Djava.library.path=${pkgs.libGL}/lib:${pkgs.libGLU}/lib:${pkgs.mesa.drivers}/lib:${pkgs.xorg.libX11}/lib:${pkgs.xorg.libXrender}/lib:${pkgs.xorg.libXext}/lib:${pkgs.xorg.libXtst}/lib:${pkgs.xorg.libXi}/lib $_JAVA_OPTIONS"
    
    # Set XDG_DATA_DIRS so IntelliJ can find system icons and themes
    export XDG_DATA_DIRS=${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}:${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}:$XDG_DATA_DIRS
    
    # Launch IntelliJ
    ${pkgs.jetbrains.idea-ultimate}/bin/idea-ultimate "$@"
  '';
in
{
  environment.systemPackages = [ intellijWrapper ];
} 