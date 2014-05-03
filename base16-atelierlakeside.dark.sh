#!/usr/bin/env bash
# Base16 Atelier Lakeside - Gnome Terminal color scheme install script
# Bram de Haan (http://atelierbram.github.io/syntax-highlighting/atelier-schemes/lakeside/)

[[ -z "$PROFILE_NAME" ]] && PROFILE_NAME="Base 16 Atelier Lakeside Dark"
[[ -z "$PROFILE_SLUG" ]] && PROFILE_SLUG="base-16-atelierlakeside-dark"
[[ -z "$DCONF" ]] && DCONF=dconf
[[ -z "$UUIDGEN" ]] && UUIDGEN=uuidgen

dset() {
  local key="$1"; shift
  local val="$1"; shift

  if [[ "$type" == "string" ]]; then
	  val="'$val'"
  fi

  "$DCONF" write "$PROFILE_KEY/$key" "$val"
}

# because dconf still doesn't have "append"
dlist_append() {
  local key="$1"; shift
  local val="$1"; shift

  local entries="$(
    {
      "$DCONF" read "$key" | tr -d '[]' | tr , "\n" | fgrep -v "$val"
      echo "'$val'"
    } | head -c-1 | tr "\n" ,
  )"

  "$DCONF" write "$key" "[$entries]"
}

# Newest versions of gnome-terminal use dconf
if which "$DCONF" > /dev/null 2>&1; then
	[[ -z "$BASE_KEY_NEW" ]] && BASE_KEY_NEW=/org/gnome/terminal/legacy/profiles:

	if [[ -n "`$DCONF list $BASE_KEY_NEW/`" ]]; then
		if which "$UUIDGEN" > /dev/null 2>&1; then
			PROFILE_SLUG=`uuidgen`
		fi

    if [[ -n "`$DCONF read $BASE_KEY_NEW/default`" ]]; then
      DEFAULT_SLUG=`$DCONF read $BASE_KEY_NEW/default | tr -d \'`
    else
      DEFAULT_SLUG=`$DCONF list $BASE_KEY_NEW/ | grep '^:' | head -n1 | tr -d :/`
    fi

		DEFAULT_KEY="$BASE_KEY_NEW/:$DEFAULT_SLUG"
		PROFILE_KEY="$BASE_KEY_NEW/:$PROFILE_SLUG"

		# copy existing settings from default profile
		$DCONF dump "$DEFAULT_KEY/" | $DCONF load "$PROFILE_KEY/"

		# add new copy to list of profiles
    dlist_append $BASE_KEY_NEW/list "$PROFILE_SLUG"

		# update profile values with theme options
		dset visible-name "'$PROFILE_NAME'"
        dset palette "['#161b1d', '#d22d72', '#568c3b', '#8a8a0f', '#257fad', '#5d5db1', '#2d8f6f', '#7ea2b4', '#5a7b8c', '#d22d72', '#568c3b', '#8a8a0f', '#257fad', '#5d5db1', '#2d8f6f', '#ebf8ff']"
		dset background-color "'#161b1d'"
		dset foreground-color "'#7ea2b4'"
		dset bold-color "'#7ea2b4'"
		dset bold-color-same-as-fg "true"
		dset use-theme-colors "false"
		dset use-theme-background "false"

             unset PROFILE_NAME
             unset PROFILE_SLUG
             unset DCONF
             unset UUIDGEN
             exit 0
	fi
fi

# Fallback for Gnome 2 and early Gnome 3
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
gset string palette "#161b1d:#d22d72:#568c3b:#8a8a0f:#257fad:#5d5db1:#2d8f6f:#7ea2b4:#5a7b8c:#d22d72:#568c3b:#8a8a0f:#257fad:#5d5db1:#2d8f6f:#ebf8ff"
gset string background_color "#161b1d"
gset string foreground_color "#7ea2b4"
gset string bold_color "#7ea2b4"
gset bool   bold_color_same_as_fg "true"
gset bool   use_theme_colors "false"
gset bool   use_theme_background "false"

unset PROFILE_NAME
unset PROFILE_SLUG
unset DCONF
unset UUIDGEN
