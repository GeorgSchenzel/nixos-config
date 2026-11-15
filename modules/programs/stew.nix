{ den, inputs, ... }:

{
  flake-file.inputs.stew.url = "git+ssh://git@github.com/GeorgSchenzel/stew";

  den.aspects.stew = {
    provides.to-users.homeManager = { config, pkgs, lib, ... }: {
      imports = [ inputs.stew.homeManagerModules.default ];

      services.stew = {
        enable = true;
        # the bento side: the stew channel, the in-box stew client and hc,
        # the skills dir, STEW_HUB — pinned to the stew input's rev by default
        bento.enable = true;
        # the stew skill and hc's stub for the host's own agents, linked
        # into ~/.claude/skills/ and ~/.config/opencode/skills/
        hostSkills.enable = true;
        # the module's default agentPackages (claude, opencode, nix and the
        # usual CLI tools) plus glab/gh, so agents can open merge requests.
        # glab/gh themselves and their token configs are Georg's, in the
        # cli-tools-desktop aspect; here they only join the units' PATH.
        agentPackages = with pkgs; [
          claude-code
          opencode
          nix
          gawk
          diffutils
          patch
          gnutar
          gzip
          xz
          unzip
          ripgrep
          fd
          jq
          curl
          less
          which
          file
          procps
          gnumake
          glab
          gh
        ];
      };

      # Remotes are written scp-style; stew normalizes every remote to its
      # https form for clones/pushes, so auth rides the credential store
      # (see cli-tools-desktop). New stews default to the bento site `desktop`.
      xdg.configFile."stew/config.yaml".text = ''
        artifacts: git@gitlab.com:SchenzelGeorg/agent-notes.git
        transcripts: git@gitlab.com:SchenzelGeorg/agent-transcripts.git
      '';
    };

    persist-home = {
      directories = [
        # artifacts mirror, transcripts checkout, skills dir
        ".local/share/stew"
        # state.json
        ".local/state/stew"
        # the hand-edited catalog repos.yaml; the declarative config.yaml
        # symlink re-lands inside the persisted dir on every activation
        ".config/stew"
      ];
    };
  };
}
