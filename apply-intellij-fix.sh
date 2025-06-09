#!/usr/bin/env bash

echo "IntelliJ Junie Plugin Fix - Complete Solution"
echo "============================================="

# Check if we're running as root
if [ "$EUID" -ne 0 ]; then
  echo "This script needs to run with sudo to apply system-wide changes."
  echo "Please run: sudo ./apply-intellij-fix.sh"
  exit 1
fi

echo "Step 1: Rebuilding NixOS with the latest configuration..."
nixos-rebuild switch

echo "Step 2: Creating environment for the current user..."
REAL_USER=$(logname || echo $SUDO_USER)
USER_HOME=$(eval echo ~$REAL_USER)

if [ -z "$REAL_USER" ]; then
  echo "Error: Could not determine the real user. Please run:"
  echo "sudo -u YOUR_USERNAME ./apply-intellij-fix.sh"
  exit 1
fi

echo "Detected real user: $REAL_USER (home: $USER_HOME)"

# Create script for the regular user to run
cat > "$USER_HOME/fix-intellij-junie.sh" << 'EOF'
#!/usr/bin/env bash

# This script can be run without sudo to fix IntelliJ Junie plugin

echo "IntelliJ Junie Plugin User Fix"
echo "============================="

# Create directories if needed
mkdir -p ~/.local/lib

# Find actual libGL path
LIBGL_PATH=$(find /nix/store -name "libGL.so.1" | grep -v "fhsenv-rootfs" | head -1)
LIBGLU_PATH=$(find /nix/store -name "libGLU.so.1" | grep -v "fhsenv-rootfs" | head -1)

echo "Using libraries:"
echo "  - libGL.so.1: $LIBGL_PATH"
echo "  - libGLU.so.1: $LIBGLU_PATH"

# Create user-level symlinks
ln -sf "$LIBGL_PATH" ~/.local/lib/libGL.so.1
ln -sf "$LIBGLU_PATH" ~/.local/lib/libGLU.so.1

# Fix Skiko if it exists
SKIKO_DIR="$HOME/.skiko"
if [ -d "$SKIKO_DIR" ]; then
  echo "Found Skiko directory, creating symlinks..."
  
  find "$SKIKO_DIR" -name "libskiko-linux-x64.so" -type f | while read -r SKIKO_LIB; do
    DIR=$(dirname "$SKIKO_LIB")
    echo "Creating symlinks in $DIR"
    
    ln -sf "$LIBGL_PATH" "$DIR/libGL.so.1"
    ln -sf "$LIBGLU_PATH" "$DIR/libGLU.so.1"
    
    echo "✓ Fixed $DIR"
  done
fi

# Create IntelliJ launcher with preloaded libraries
cat > ~/.local/bin/intellij-preload << 'EOF2'
#!/usr/bin/env bash
LD_PRELOAD=~/.local/lib/libGL.so.1:~/.local/lib/libGLU.so.1:$LD_PRELOAD \
LD_LIBRARY_PATH=~/.local/lib:$LD_LIBRARY_PATH \
intellij-idea-ultimate "$@"
EOF2

chmod +x ~/.local/bin/intellij-preload

echo "Done! Please run IntelliJ using: intellij-preload"
echo "Or, if that doesn't work: LD_PRELOAD=$LIBGL_PATH intellij-idea-ultimate"
EOF

# Make the script executable and set ownership
chmod +x "$USER_HOME/fix-intellij-junie.sh"
chown $REAL_USER:$REAL_USER "$USER_HOME/fix-intellij-junie.sh"

echo "Step 3: Creating user directory for libraries..."
mkdir -p "$USER_HOME/.local/bin" "$USER_HOME/.local/lib"
chown -R $REAL_USER:$REAL_USER "$USER_HOME/.local"

echo ""
echo "=========== INSTALLATION COMPLETE ============="
echo ""
echo "To complete the fix, please run the following command as your normal user (not root):"
echo "  ~/fix-intellij-junie.sh"
echo ""
echo "Then, restart your system and run IntelliJ with the following command:"
echo "  intellij-preload"
echo "" 