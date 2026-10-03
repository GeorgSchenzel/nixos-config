#!/usr/bin/env bash
set -euo pipefail

state_file="${XDG_CACHE_HOME:-$HOME/.cache}/voxtype/state"

text=""
tooltip=""
if [[ -s $state_file ]]; then
  content=$(tr -d '\n' < "$state_file" | cut -c1-48)
  text="dictation: $content"
  tooltip=$(cut -c1-400 "$state_file")
fi

class=empty
[[ -n $text ]] && class=active

jq -cn --arg text "$text" --arg tooltip "$tooltip" --arg class "$class" \
  '{ text: $text, tooltip: $tooltip, class: $class }'
