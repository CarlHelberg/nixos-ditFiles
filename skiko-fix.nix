{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Create a dedicated script to fix Skiko library issues in IntelliJ plugins
    (pkgs.writeShellScriptBin "fix-skiko" ''
      #!/usr/bin/env bash
      
      echo "IntelliJ Junie Plugin Fixer - Skiko library helper"
      echo "=================================================="
      
      SKIKO_DIR="$HOME/.skiko"
      
      # Use the exact paths from nixpkgs
      LIBGL_PATH="${pkgs.libGL}/lib/libGL.so.1"
      LIBGLU_PATH="${pkgs.libGLU}/lib/libGLU.so.1"
      
      echo "Using libraries:"
      echo "  - libGL.so.1: $LIBGL_PATH"
      echo "  - libGLU.so.1: $LIBGLU_PATH"
      
      if [ ! -f "$LIBGL_PATH" ]; then
        echo "Error: Could not find libGL.so.1 at $LIBGL_PATH"
        echo "This is unexpected. Please run: sudo nixos-rebuild switch"
        exit 1
      fi
      
      if [ -d "$SKIKO_DIR" ]; then
        echo "Found Skiko directory at $SKIKO_DIR"
        echo "Creating libGL.so symlinks in Skiko directories..."
        
        # Find all libskiko-linux-x64.so files and create symlinks in their directories
        find "$SKIKO_DIR" -name "libskiko-linux-x64.so" -type f | while read -r SKIKO_LIB; do
          DIR=$(dirname "$SKIKO_LIB")
          echo "Creating symlinks in $DIR"
          
          # Create symlinks to system libraries
          ln -sf "$LIBGL_PATH" "$DIR/libGL.so.1"
          ln -sf "$LIBGLU_PATH" "$DIR/libGLU.so.1"
          
          # Create an additional preload wrapper just in case
          cat > "$DIR/preload-wrapper.sh" << EOF
#!/bin/bash
LD_PRELOAD=$LIBGL_PATH:\$LD_PRELOAD
export LD_PRELOAD
exec "\$@"
EOF
          chmod +x "$DIR/preload-wrapper.sh"
          
          echo "✓ Fixed $DIR"
        done
        
        echo "Done! You can now restart IntelliJ and try the Junie plugin again."
        echo "If it still doesn't work, run intellij with the following command:"
        echo "LD_PRELOAD=$LIBGL_PATH intellij-idea-ultimate"
      else
        echo "Skiko directory not found at $SKIKO_DIR"
        echo "Please follow these steps:"
        echo " 1. Launch IntelliJ using the intellij-idea-ultimate command"
        echo " 2. Try to activate the Junie plugin first (it will fail, but will create the Skiko directory)"
        echo " 3. Run this script again"
        echo " 4. Restart IntelliJ"
      fi
    '')
  ];
} 