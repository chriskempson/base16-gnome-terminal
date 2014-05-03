#!/usr/bin/env bash
# Base16 Pop - Gnome Terminal color scheme install script
# Chris Kempson (http://chriskempson.com)

[[ -z "$PROFILE_NAME" ]] && PROFILE_NAME="Base 16 Pop"
[[ -z "$PROFILE_SLUG" ]] && PROFILE_SLUG="base-16-pop"
[[ -z "$GCONFTOOL" ]] && GCONFTOOL=gconftool
[[ -z "$BASE_KEY" ]] && BASE_KEY=/apps/gnome-terminal/profiles

PROFILE_KEY="$BASE_KEY/$PROFILE_SLUG"

gset() {
    local type="$1"; shift
    local key="$1"; shift
    local val="$1"; shift

    "$GCONFTOOL" --set --type "$type" "$PROFILE_KEY/$key" -- "$val"
}

# Because gconftool doesn't have "append"
glist_append() {
    local type="$1"; shift
    local key="$1"; shift
    local val="$1"; shift

    local entries="$(
        {
            "$GCONFTOOL" --get "$key" | tr -d '[]' | tr , "\n" | fgrep -v "$val"
            echo "$val"
        } | head -c-1 | tr "\n" ,
    )"

    "$GCONFTOOL" --set --type list --list-type $type "$key" "[$entries]"
}

# Append the Base16 profile to the profile list
glist_append string /apps/gnome-terminal/global/profile_list "$PROFILE_SLUG"

gset string visible_name "$PROFILE_NAME"
gset string palette "#000000000000:#220022002200:#330033003300:#550055005500:#bb00bb00bb00:#dd00dd00dd00:#ee00ee00ee00:#ffffffffffff:#eebb000088aa:#ff2299333333:#ff88ccaa1122:#3377bb334499:#0000aaaabbbb:#00ee55aa9944:#bb3311ee88dd:#77aa22dd0000"
gset string background_color "#000000000000"
gset string foreground_color "#dd00dd00dd00"
gset string bold_color "#dd00dd00dd00"
gset bool bold_color_same_as_fg "true"
gset bool use_theme_colors "false"
gset bool use_theme_background "false"