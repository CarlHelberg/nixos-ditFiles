#!/usr/bin/env bash

echo "IntelliJ Junie Plugin Fixer - Skiko library helper"
echo "=================================================="

SKIKO_DIR="$HOME/.skiko"

# Find actual libGL path
LIBGL_PATH=$(find /nix/store -name "libGL.so.1" | grep -v "fhsenv-rootfs" | head -1)
LIBGLU_PATH=$(find /nix/store -name "libGLU.so.1" | grep -v "fhsenv-rootfs" | head -1)

echo "Using libraries:"
echo "  - libGL.so.1: $LIBGL_PATH"
echo "  - libGLU.so.1: $LIBGLU_PATH"

if [ -z "$LIBGL_PATH" ]; then
  echo "Error: Could not find libGL.so.1 in the system. Please run:"
  echo "  sudo nixos-rebuild switch"
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
    
    if [ -n "$LIBGLU_PATH" ]; then
      ln -sf "$LIBGLU_PATH" "$DIR/libGLU.so.1"
    fi
    
    # Make sure they're executable
    chmod +x "$DIR/libGL.so.1" "$DIR/libGLU.so.1" 2>/dev/null || true
    
    echo "✓ Fixed $DIR"
  done
  
  echo "Done! You can now restart IntelliJ and try the Junie plugin again."
else
  echo "Skiko directory not found at $SKIKO_DIR"
  echo "Please follow these steps:"
  echo " 1. Launch IntelliJ using the intellij-idea-ultimate command"
  echo " 2. Try to activate the Junie plugin first (it will fail, but will create the Skiko directory)"
  echo " 3. Run this script again"
  echo " 4. Restart IntelliJ"
fi 