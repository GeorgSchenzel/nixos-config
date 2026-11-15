{ den, ... }:

{
  den.aspects.cli-tools-desktop = {
    includes = [
      den.aspects.cli-tools
    ];

    os = { pkgs, ... }: {
      environment.systemPackages = with pkgs; [
        ffmpeg
        devenv
      ];
    };

    provides.to-users.homeManager = { config, pkgs, ... }:
    let
      # devenv only trusts exact paths, so every clone/worktree would need
      # `devenv allow`. Auto-allow git repos whose origin is one of my own
      # remotes or that have no remote; anything else still asks. Runs before _devenv_hook each
      # prompt and keeps $? intact since that hook reports it.
      autoAllow = ''
        _devenv_auto_allow() {
          local s=$? d=$PWD url
          [[ "$PWD" == "''${_devenv_auto_allow_last:-}" ]] && return $s
          _devenv_auto_allow_last=$PWD
          while [[ -n "$d" && ! -e "$d/devenv.yaml" ]]; do d=''${d%/*}; done
          [[ -n "$d" ]] || return $s
          grep -qF "\"path\":\"$d\"" "${config.xdg.dataHome}/devenv/allowed" 2>/dev/null && return $s
          git -C "$d" rev-parse --git-dir >/dev/null 2>&1 || return $s
          url=$(git -C "$d" remote get-url origin 2>/dev/null | tr '[:upper:]' '[:lower:]')
          # local-only repos (no remotes at all) are mine too
          if [[ -z "$(git -C "$d" remote)" ]] ||
             [[ "$url" =~ (^|[@/])(github\.com[:/]georgschenzel/|gitlab\.com[:/]schenzelgeorg/|gitlab\.tuwien\.ac\.at[:/]) ]]; then
            (cd "$d" && devenv allow >/dev/null)
          fi
          return $s
        }
      '';
    in
    {
      # native devenv auto-activation on cd (devenv >= 2.0, replaces direnv)
      programs.zsh.initContent = ''
        eval "$(devenv hook zsh)"
        ${autoAllow}
        precmd_functions=(_devenv_auto_allow $precmd_functions)
      '';
      programs.bash.initExtra = ''
        eval "$(devenv hook bash)"
        ${autoAllow}
        PROMPT_COMMAND="_devenv_auto_allow;$PROMPT_COMMAND"
      '';

      home.packages = with pkgs; [
        tika
        pdftk
        openconnect
        kubectl
        kubernetes-helm
        k9s
        nodejs
        bun
        uv
        # claude/agents run `python3` non-interactively, where shell aliases
        # don't apply — provide a real interpreter; uv reuses it too
        python3
        just
        jdk21
        maven
        quarkus
        glab
        gh
      ];

      # git host auth, independent of any agent tooling: one api-scoped
      # fine-grained token per host in the vault (git/gitlab-com,
      # git/github-com), rendered into the credential store (git over
      # https, also what stew's normalized remotes use) and the CLI
      # configs (MRs, comments). glab refuses anything but 0600.
      sops.secrets = {
        "git/gitlab-com" = { };
        "git/github-com" = { };
      };

      sops.templates = {
        "git-credentials" = {
          path = "${config.home.homeDirectory}/.git-credentials";
          mode = "0600";
          content = ''
            https://SchenzelGeorg:${config.sops.placeholder."git/gitlab-com"}@gitlab.com
            https://GeorgSchenzel:${config.sops.placeholder."git/github-com"}@github.com
          '';
        };
        "glab-config" = {
          path = "${config.home.homeDirectory}/.config/glab-cli/config.yml";
          mode = "0600";
          content = ''
            hosts:
              gitlab.com:
                token: ${config.sops.placeholder."git/gitlab-com"}
          '';
        };
        "gh-hosts" = {
          path = "${config.home.homeDirectory}/.config/gh/hosts.yml";
          mode = "0600";
          content = ''
            github.com:
                oauth_token: ${config.sops.placeholder."git/github-com"}
                user: GeorgSchenzel
                git_protocol: ssh
          '';
        };
      };
    };

    persist-home = {
      directories = [
        ".local/share/zsh" # zsh history, see shell-aliases
        ".local/share/devenv" # `devenv allow` trust list, gc roots
      ];
      files = [
        ".bash_history"
      ];
    };
  };
}
