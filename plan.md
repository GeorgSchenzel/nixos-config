# Migration Plan: flake-parts Dendritic → Den

## Current State

- **Framework**: flake-parts + import-tree + flake-file
- **Class routing**: Bracket tags (`[N]`, `[D]`, `[n]`, `[d]`, `[G]`) via `flake.modules.<class>.<name>`
- **Feature inheritance**: Layered system types (1-minimal → 2-default → 3-cli → 4-desktop)
- **Hosts**: desktop (NixOS x86_64-linux, impermanence), mbp (Darwin aarch64-darwin)
- **Users**: georg (both hosts)
- **Impermanence**: `mkIfPersistence` helper + co-located `impermanence.nix` per feature

## Decisions

- **Den-only** (no flake-parts): simpler flake.nix, den handles all output generation
- **Big bang** migration: rewrite everything at once
- **Drop pkgs-by-name**: not currently used
- **VM variant**: separate host (`desktop-vm`)
- **Impermanence**: custom forward classes (`impermanence-system`, `impermanence-home`) with guards

## Target Structure

```
modules/
├── den.nix                            # den.flakeModule, host/user declarations, den.default
├── classes.nix                        # Custom forward classes: impermanence-system, impermanence-home
├── aspects/
│   ├── desktop.nix                    # Host aspect (includes all desktop features)
│   ├── desktop-vm.nix                 # Separate VM host aspect (no impermanence/disko/boot)
│   ├── mbp.nix                        # Host aspect (includes all mbp features)
│   ├── georg.nix                      # User aspect: primary-user, HM config
│   ├── nix-settings.nix               # nix daemon, unfree, overlays (nixos+darwin+homeManager)
│   ├── cli-tools.nix                  # vim, git, ffmpeg, dev tools, k8s + persistence
│   ├── desktop-apps.nix               # firefox, vscode, obsidian, etc. + persistence
│   ├── desktop-environment.nix        # sway, greetd, nvidia, rofi
│   ├── ai-tools.nix                   # opencode + sops secrets + persistence
│   ├── ssh.nix                        # openssh service + keys + persistence
│   ├── secrets.nix                    # sops-nix (nixos+darwin+homeManager)
│   ├── yabai.nix                      # darwin tiling WM
│   ├── audio.nix                      # pipewire (nixos)
│   ├── firmware.nix                   # firmware (nixos)
│   ├── impermanence.nix               # core setup, rollback, minimum persistence
│   ├── disko.nix                      # BTRFS partitioning (nixos)
│   └── boot.nix                       # systemd-boot + dual-boot (nixos)
```

## Key Architectural Changes

| Concept | Current | Den |
|---------|---------|-----|
| Hosts | `modules/hosts/{desktop,mbp}/flake-parts.nix` + `configuration.nix` | `den.hosts.<system>.<name>` in `den.nix` |
| Users | `modules/users/georg/georg.nix` | `den.hosts.*.*.users.georg` in `den.nix`, enhanced in `aspects/georg.nix` |
| Feature routing | Bracket tags + `flake.modules.<class>.<name>` | Per-class keys in each aspect: `nixos = { ... }; homeManager = { ... };` |
| Layered inheritance | system-minimal → system-default → system-cli → system-desktop | `den.default` (globals) + aspect `includes` (composition DAG) |
| Home Manager | Manual wiring via `home-manager.sharedModules` | `den.schema.user.classes = [ "homeManager" ]` + den's HM pipeline |
| Global settings | Scattered across system-minimal, system-default | `den.default` for stateVersion, nix settings, batteries |
| Host-specific values | `systemConstants` custom option | Freeform host attrs: `host.diskDevice`, `host.btrfsPartition` |
| User creation | Manual per-class in `georg.nix` | `den.provides.define-user` + `den.provides.primary-user` batteries |
| Impermanence | `mkIfPersistence` helper + co-located files | Custom forward classes with guards, inline in each aspect |

## Custom Classes: impermanence-system and impermanence-home

```nix
# modules/classes.nix
{ den, lib, ... }:

let
  impermanence-system = { class, aspect-chain }:
    den.provides.forward {
      each = lib.singleton true;
      fromClass = _: "impermanence-system";
      intoClass = _: class;
      intoPath = _: { config, ... }:
        [ "environment" "persistence" "/persist/system" ];
      fromAspect = _: lib.head aspect-chain;
      guard = { options, ... }: options ? environment.persistence;
    };

  impermanence-home = { class, aspect-chain }:
    den.provides.forward {
      each = lib.singleton true;
      fromClass = _: "impermanence-home";
      intoClass = _: "homeManager";
      intoPath = _: { config, ... }:
        [ "home" "persistence" "/persist/home" ];
      fromAspect = _: lib.head aspect-chain;
      guard = { options, ... }: options ? home.persistence;
    };
in
{
  den.ctx.host.includes = [ impermanence-system ];
  den.ctx.user.includes = [ impermanence-home ];
}
```

Any aspect can then declare persistence inline — on hosts without impermanence, the guard silently skips:

```nix
den.aspects.cli-tools = {
  homeManager.home.packages = [ ... ];
  impermanence-system.files = [{ directory = "/var/lib/nixos"; }];
  impermanence-home.files = [ ".bash_history" ];
};
```

### Per-Feature Persistence Map

| Aspect | impermanence-system | impermanence-home |
|--------|--------------------|--------------------|
| impermanence | `/var/log`, `/var/lib/nixos`, `/etc/machine-id`, NetworkManager, coredump | — |
| ssh | SSH host keys | `.ssh` |
| cli-tools | — | `.bash_history` |
| desktop-apps | — | `.mozilla/firefox`, `.thunderbird`, `.config/Code` |
| ai-tools | — | `.local/share/opencode`, `.local/state/opencode` |
| georg | — | `nixos-config`, `hot` |

## Host Declarations (in den.nix)

```nix
den.hosts.x86_64-linux.desktop = {
  users.georg = {};
  diskDevice = "/dev/nvme0n1";
  btrfsPartition = "/dev/disk/by-label/NIXROOT";
};

den.hosts.x86_64-linux.desktop-vm = {
  users.georg = {};
  diskDevice = "/dev/vda";
};

den.hosts.aarch64-darwin.mbp = {
  users.georg = {};
};
```

## Aspect Composition (includes DAG)

```
den.default
  includes: [ den.provides.hostname, den.provides.define-user ]
  nixos: stateVersion
  homeManager: stateVersion

  ├── desktop
  │     includes: [ impermanence, disko, boot, firmware, audio,
  │                  cli-tools, desktop-environment, desktop-apps,
  │                  ai-tools, ssh, secrets, nix-settings ]
  │     nixos: hardware config, audio rules, nvidia
  │
  ├── desktop-vm
  │     includes: [ cli-tools, desktop-environment, desktop-apps,
  │                  ai-tools, ssh, secrets, nix-settings ]
  │     nixos: VM overrides (virtualisation.vmVariantWithDisko, port forward)
  │
  ├── mbp
  │     includes: [ cli-tools, desktop-apps, ai-tools,
  │                  ssh, secrets, yabai, nix-settings ]
  │     darwin: system.primaryUser, mac-app-util
  │
  └── georg
        includes: [ den.provides.primary-user ]
        homeManager: username, homeDirectory, git config
        impermanence-home: .ssh, nixos-config, hot
```

## flake.nix (Final)

```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-darwin.url = "github:nixos/nixpkgs/nixpkgs-25.11-darwin";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-25.11";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    den.url = "github:vic/den";
    import-tree.url = "github:vic/import-tree";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence.url = "github:nix-community/impermanence";
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    mac-app-util.url = "github:hraban/mac-app-util";
    opencode.url = "github:anomalyco/opencode";
  };

  outputs = inputs:
    (inputs.nixpkgs.lib.evalModules {
      modules = [ (inputs.import-tree ./modules) ];
      specialArgs.inputs = inputs;
    }).config.flake;
}
```

## What Gets Removed

- **Inputs**: `flake-parts`, `flake-file`, `pkgs-by-name-for-flake-parts`
- **Infrastructure**: `modules/nix/` (lib, tools, flake-parts modules)
- **Bracket tags**: All `[N]`, `[D]`, `[n]`, `[d]`, `[G]` directory suffixes
- **System types**: `modules/system/system types/` (layered inheritance chain)
- **Host dirs**: `modules/hosts/{desktop,mbp}/` (replaced by aspect includes)
- **User dirs**: `modules/users/georg/` (replaced by den user aspect)
- **Scattered impermanence**: All per-feature `impermanence.nix` files (replaced by inline classes)
- **systemConstants**: Custom option (replaced by freeform host attrs)

## Migration Steps (Big Bang)

1. **Create new modules/ structure**: Write `den.nix`, `classes.nix`, and all aspect files
2. **Write new `flake.nix`**: Minimal den-only form
3. **Remove old modules/**: Delete entire current modules directory contents
4. **Update flake.lock**: `nix flake lock --update-input den` (add den), remove stale inputs
5. **Build & test**: `nix build .#nixosConfigurations.desktop.config.system.build.toplevel`
6. **Test VM**: `nix build .#nixosConfigurations.desktop-vm.config.system.build.vmWithDisko`
7. **Test darwin**: `nix build .#darwinConfigurations.mbp.config.system.build.toplevel`
8. **Clean up**: Remove `.agents/`, update `AGENTS.md`, update `README.md`
