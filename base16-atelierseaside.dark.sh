#!/usr/bin/env bash
# Base16 Atelier Seaside - Gnome Terminal color scheme install script
# Bram de Haan (http://atelierbram.github.io/syntax-highlighting/atelier-schemes/seaside/)

[[ -z "$PROFILE_NAME" ]] && PROFILE_NAME="Base 16 Atelier Seaside Dark"
[[ -z "$PROFILE_SLUG" ]] && PROFILE_SLUG="base-16-atelierseaside-dark"
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
        dset palette "['#131513', '#e6193c', '#29a329', '#c3c322', '#3d62f5', '#ad2bee', '#1999b3', '#8ca68c', '#687d68', '#e6193c', '#29a329', '#c3c322', '#3d62f5', '#ad2bee', '#1999b3', '#f0fff0']"
		dset background-color "'#131513'"
		dset foreground-color "'#8ca68c'"
		dset bold-color "'#8ca68c'"
		dset bold-color-same-as-fg "true"
		dset use-theme-colors "false"
		dset use-theme-background "false"

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
gset string palette "#131513:#e6193c:#29a329:#c3c322:#3d62f5:#ad2bee:#1999b3:#8ca68c:#687d68:#e6193c:#29a329:#c3c322:#3d62f5:#ad2bee:#1999b3:#f0fff0"
gset string background_color "#131513"
gset string foreground_color "#8ca68c"
gset string bold_color "#8ca68c"
gset bool   bold_color_same_as_fg "true"
gset bool   use_theme_colors "false"
gset bool   use_theme_background "false"
