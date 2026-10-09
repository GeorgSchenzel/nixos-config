#!/usr/bin/env bash
set -euo pipefail

# keep in sync with the keybind grid in desktop-environment.nix
rows=('12345' 'qwert' 'asdfg' 'yxcvb')

declare -A focused=() urgent=() visible=() windows=()

emit() {
  local name f u v w row char cell text tooltip i
  # stale state must not survive a re-read: sway destroys workspaces
  # (empty ones on switch-away), and get_tree won't list them anymore
  focused=()
  urgent=()
  visible=()
  windows=()
  while IFS=$'\t' read -r name f u v w; do
    focused[$name]=$f
    urgent[$name]=$u
    visible[$name]=$v
    windows[$name]=$w
  done < <(swaymsg -t get_tree | jq -r '
    .nodes[] | select(.name != "__i3") | . as $out
    | .nodes[] | select(.type == "workspace")
    | [ .name,
        (([ .. | objects | select(.focused == true) ] | length > 0) | tostring),
        (([ .. | objects | select(.urgent == true) ] | length > 0) | tostring),
        ((.name == $out.current_workspace) | tostring),
        ( [ .. | objects
            | select(.type == "con" and ((.app_id != null) or (.window != null))) ]
          | length | tostring )
      ]
    | @tsv
  ')

  text=""
  tooltip=""
  for row in "${rows[@]}"; do
    if [[ -n $text ]]; then
      text+=$'\n'
    fi
    for (( i = 0; i < ${#row}; i++ )); do
      char=${row:i:1}
      if [[ ${urgent[$char]:-} == true ]]; then
        cell="<span background='#f38ba8' color='#1e1e2e' font_weight='bold'> $char </span>"
      elif [[ ${focused[$char]:-} == true ]]; then
        cell="<span background='#89b4fa' color='#1e1e2e' font_weight='bold'> $char </span>"
      elif [[ ${visible[$char]:-} == true ]]; then
        cell=" <span color='#f5e0dc' underline='single'>$char</span> "
      elif (( ${windows[$char]:-0} > 0 )); then
        cell=" <span color='#cdd6f4'>$char</span> "
      else
        cell=" <span color='#585b70'>$char</span> "
      fi
      text+=$cell
      if (( ${windows[$char]:-0} > 0 )); then
        tooltip+="$char: ${windows[$char]} windows"$'\n'
      fi
    done
  done

  jq -cn --arg text "$text" --arg tooltip "$tooltip" \
    '{ text: $text, tooltip: $tooltip, class: "grid" }'
}

emit
swaymsg -t subscribe -m '["workspace", "window"]' | while read -r _event; do
  emit
done
