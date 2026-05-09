# Agents Guide

This repo uses [den](https://github.com/denful/den) - Aspect-oriented, context-driven Dendritic Nix configurations.

## Quick Overview

**Den** takes the Dendritic pattern to the function-level, creating parametric configurations that become specific when applied to hosts/users:

- **Aspects**: Functions taking context (host, user) and returning modules for different Nix classes (nixos, darwin, homeManager, hjem, etc.)
- **Hosts/Users/Homes**: Defined declaratively, aspects are shared across them
- **Context Pipeline**: `den.ctx` transformations traverse host->users->homes, aggregating dependencies
- **Custom Nix Classes**: Extensible class system (user, persys, microvm, etc.) via `den.provides.forward`
- **Zero Dependencies**: `den.lib` is domain-agnostic, works with/without flakes, flake-parts, or any module system

## Den Documentation (fetch on demand)

Key documentation pages - fetch these when working on specific tasks:

- **Migration**: [From Flake To Den](https://den.denful.dev/guides/from-flake-to-den/) - guide for migrating from flake-based setups
- **Core Concepts**: [Core Principles](https://den.denful.dev/explanation/core-principles/) - fundamental den concepts
- **Getting Started**: [From Zero To Den](https://den.denful.dev/guides/from-zero-to-den/) - fresh setup guide
- **Custom Classes**: [Custom Nix Classes](https://den.denful.dev/guides/custom-classes/) - creating custom Nix classes
- **Home Manager**: [Homes Integration](https://den.denful.dev/guides/home-manager/) - home-manager/hjem setup
- **Batteries**: [Batteries](https://den.denful.dev/guides/batteries/) - built-in reusable aspects
- **Mutual Providers**: [Mutual Providers](https://den.denful.dev/guides/mutual/) - cross-aspect contributions
- **Namespaces**: [Sharing Namespaces](https://den.denful.dev/guides/namespaces/) - organizing aspects
- **Angle Brackets**: [Angle Brackets](https://den.denful.dev/guides/angle-brackets/) - file naming conventions
- **Context Pipeline**: [Context Pipeline](https://den.denful.dev/explanation/context-pipeline/) - how den.ctx works
- **Repo**: [github.com/denful/den](https://github.com/denful/den) - source code and README with extensive examples

## Migration Status

This repo is being refactored from a flake-parts Dendritic pattern to den. The old `.agents/docs/` contain flake-parts-specific guides that are being replaced.

## Common Commands

```bash
# Check if flake is valid
nix flake check

# Update flake inputs
nix flake update

# Build a specific host configuration
nix build .#nixosConfigurations.linux-desktop.config.system.build.toplevel

# Build a darwin configuration
nix build .#darwinConfigurations.macbook.config.system.build.toplevel

# Build a home-manager standalone configuration
nix build .#homeConfigurations.bob.activationPackage

# Build VM
nix build .#nixosConfigurations.desktop.config.system.build.vm
# Start VM
./result/bin/run-nixos-vm

# Build VM with disko
nix build .#nixosConfigurations.desktop.config.system.build.vmWithDisko
# Start VM
./result/bin/disko-vm
```

## Important Notes

- When in doubt about den patterns, fetch the relevant docs page from the list above
- The den README on GitHub contains extensive code examples for hosts, users, aspects, and custom classes
- Den works with flake-parts but does not require it - the migration should simplify the setup
