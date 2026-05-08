#!/usr/bin/env bash
# Create baselines:
#   nix eval .#nixosConfigurations.desktop.config.system.build.toplevel.drvPath --raw > desktop.drv
#   nix eval .#darwinConfigurations.mbp.config.system.build.toplevel.drvPath --raw > mbp.drv
set -euo pipefail
DESKTOP_OLD=$(cat desktop.drv)
MBP_OLD=$(cat mbp.drv)
DESKTOP_NEW=$(nix eval .#nixosConfigurations.desktop.config.system.build.toplevel.drvPath --raw)
MBP_NEW=$(nix eval .#darwinConfigurations.mbp.config.system.build.toplevel.drvPath --raw)
echo "=== Desktop ==="
nix shell nixpkgs#nix-diff -c nix-diff "$DESKTOP_OLD" "$DESKTOP_NEW"
echo "=== MBP ==="
nix shell nixpkgs#nix-diff -c nix-diff "$MBP_OLD" "$MBP_NEW"
