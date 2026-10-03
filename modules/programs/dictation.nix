{ den, lib, ... }:

{
  den.aspects.dictation = {
    provides.to-users.homeManager =
      { pkgs, config, ... }:
      lib.mkIf pkgs.stdenv.isLinux (
        let
          modelDir = pkgs.runCommand "parakeet-unified-en-0.6b-int8" { } ''
            mkdir -p $out
            ln -s ${pkgs.fetchurl {
              url = "https://huggingface.co/bobNight/parakeet-unified-en-0.6b-onnx/resolve/main/encoder.int8.onnx";
              hash = "sha256-yBrfq3djTgDBZooiGhTyRMX7NAnnwU7uuvasljQlkQ8=";
            }} $out/encoder.int8.onnx
            ln -s ${pkgs.fetchurl {
              url = "https://huggingface.co/bobNight/parakeet-unified-en-0.6b-onnx/resolve/main/encoder.int8.onnx.data";
              hash = "sha256-PVTdBGRsFWd70oRKhN83cLEswc4YNIH3tuDe8xySEUo=";
            }} $out/encoder.int8.onnx.data
            ln -s ${pkgs.fetchurl {
              url = "https://huggingface.co/bobNight/parakeet-unified-en-0.6b-onnx/resolve/main/decoder_joint.int8.onnx";
              hash = "sha256-f3atXzUDXyVjAHVpnGyUKiwMBf9CyzmPlm88JW0Ujh4=";
            }} $out/decoder_joint.int8.onnx
            ln -s ${pkgs.fetchurl {
              url = "https://huggingface.co/bobNight/parakeet-unified-en-0.6b-onnx/resolve/main/tokenizer.model";
              hash = "sha256-B9TlpjhApTqy1NEG0odHaBQ/s/vdR5OLORDS2gW/sKk=";
            }} $out/tokenizer.model
            ln -s ${pkgs.fetchurl {
              url = "https://huggingface.co/bobNight/parakeet-unified-en-0.6b-onnx/resolve/main/vocab.txt";
              hash = "sha256-rmHJt0PLR8BM5vsTBEQhBkbtD0DJU8d+4YVRhZYK+U8=";
            }} $out/vocab.txt
          '';
          # Explicit path (not "auto" -> /run/user/<uid>) so i3status
          # read_file can reference it without knowing the uid.
          stateFile = "${config.home.homeDirectory}/.cache/voxtype/state";
          mod = config.wayland.windowManager.sway.config.modifier;
        in
        {
          services.voxtype = {
            enable = true;
            package = pkgs.voxtype-onnx;
            settings = {
              engine = "parakeet";
              state_file = stateFile;
              audio.max_duration_secs = 300;
              hotkey = {
                enabled = false;
                mode = "toggle";
              };
              osd.enabled = false;
              parakeet = {
                model = "${modelDir}";
                streaming = true;
                on_demand_loading = true;
                # voxtype 0.7.5 defaults (1.5/0.5/0.5) fail parakeet-rs
                # validation: mel-frame counts must be divisible by 8.
                streaming_chunk_secs = 0.56;
                streaming_left_context_secs = 5.6;
                streaming_right_context_secs = 0.56;
              };
            };
          };

          systemd.user.services.voxtype = {
            Unit = {
              PartOf = lib.mkForce [ "graphical-session.target" ];
              After = [ "graphical-session.target" ];
            };
            Install.WantedBy = lib.mkForce [ "graphical-session.target" ];
          };

          wayland.windowManager.sway.extraConfig = ''
            bindsym ${mod}+Shift+v exec ${pkgs.voxtype-onnx}/bin/voxtype record toggle
          '';

          # ~/.cache is wiped by impermanence on boot; ensure the
          # state dir exists before the daemon wants to write it.
          home.file.".cache/voxtype/.keep".text = "";

          programs.i3status = {
            enable = true;
            general.interval = 2;
            modules."read_file voxtype" = {
              position = 9;
              settings = {
                path = stateFile;
                format = "dictation: %content";
                format_bad = "";
              };
            };
          };
        }
      );
  };
}
