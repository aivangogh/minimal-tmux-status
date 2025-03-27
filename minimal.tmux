#!/usr/bin/env bash

get_tmux_option() {
  local option=$1
  local default_value="$2"

  local option_value
  option_value=$(tmux show-options -gqv "$option")

  if [ "$option_value" != "" ]; then
    echo "$option_value"
    return
  fi
  echo "$default_value"
}

default_color="#[bg=default,fg=default,bold]"

# Variables
bg=$(get_tmux_option "@minimal-tmux-bg" '#698DDA')
fg=$(get_tmux_option "@minimal-tmux-fg" '#000000')
active_fg=$(get_tmux_option "@minimal-tmux-active-fg" "$fg")  # Ensure this is set correctly

use_arrow=$(get_tmux_option "@minimal-tmux-use-arrow" false)
larrow="$("$use_arrow" && get_tmux_option "@minimal-tmux-left-arrow" "")"
rarrow="$("$use_arrow" && get_tmux_option "@minimal-tmux-right-arrow" "")"

status=$(get_tmux_option "@minimal-tmux-status" "bottom")
justify=$(get_tmux_option "@minimal-tmux-justify" "centre")

indicator_state=$(get_tmux_option "@minimal-tmux-indicator" true)
indicator_str=$(get_tmux_option "@minimal-tmux-indicator-str" " tmux ")
indicator=$("$indicator_state" && echo " $indicator_str ")

right_state=$(get_tmux_option "@minimal-tmux-right" true)
left_state=$(get_tmux_option "@minimal-tmux-left" true)

status_right=$("$right_state" && get_tmux_option "@minimal-tmux-status-right" "#S")
status_left=$("$left_state" && get_tmux_option "@minimal-tmux-status-left" "${default_color}#{?client_prefix,,${indicator}}#[bg=${bg},fg=${fg},bold]#{?client_prefix,${indicator},}${default_color}")
status_right_extra="$status_right$(get_tmux_option "@minimal-tmux-status-right-extra" "")"
status_left_extra="$status_left$(get_tmux_option "@minimal-tmux-status-left-extra" "")"

# Window status format: <index>: <window_name>
window_status_format=$(get_tmux_option "@minimal-tmux-window-status-format" '#I: #W ')

expanded_icon=$(get_tmux_option "@minimal-tmux-expanded-icon" '󰊓 ')
show_expanded_icon_for_all_tabs=$(get_tmux_option "@minimal-tmux-show-expanded-icon-for-all-tabs" false)

# Setting the options in tmux
tmux set-option -g status-position "$status"
tmux set-option -g status-style bg=default,fg=default
tmux set-option -g status-justify "$justify"

tmux set-option -g status-left "$status_left_extra"
tmux set-option -g status-right "$status_right_extra"

# Inactive windows: Use the fg color
tmux set-option -g window-status-format "#[fg=${fg}]${window_status_format}"
"$show_expanded_icon_for_all_tabs" && tmux set-option -g window-status-format "#[fg=${fg}] ${window_status_format}#{?window_zoomed_flag,${expanded_icon},}"

# Active window: Use the active_fg color, no arrows
tmux set-option -g window-status-current-format "#[fg=${active_fg}]${window_status_format}#{?window_zoomed_flag,${expanded_icon},}"
