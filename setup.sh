#!/bin/bash

echo 'Setting GNOME settings.'

# Make sure dbus is available then set gsettings
export DISPLAY=:0

if [[ -z "$DBUS_SESSION_BUS_ADDRESS" ]]; then
	# No DBUS session running, start one.
	eval `dbus-launch --sh-syntax`
fi

# Enabled extensions
_extensions="['user-theme@gnome-shell-extensions.gcampax.github.com', 'dash-to-dock@micxgx.gmail.com', 'sound-output-device-chooser@kgshank.net', 'drive-menu@gnome-shell-extensions.gcampax.github.com']"
gsettings set org.gnome.shell enabled-extensions "${_extensions}"

# Extension - dash-to-dock Settings
gsettings set org.gnome.shell.extensions.dash-to-dock dock-position 'BOTTOM'
gsettings set org.gnome.shell.extensions.dash-to-dock preferred-monitor -1
gsettings set org.gnome.shell.extensions.dash-to-dock transparency-mode 'ADAPTIVE'

# Extension - sound-output-device Settings
gsettings set org.gnome.shell.extensions.sound-output-device-chooser icon-theme 'monochrome'
gsettings set org.gnome.shell.extensions.sound-output-device-chooser show-output-devices true
gsettings set org.gnome.shell.extensions.sound-output-device-chooser show-profiles true

# Gnome Weather
gsettings set org.gnome.Weather.Application locations "[<(uint32 2, <('Warsaw', 'EPWA', true, [(0.91048009894147275, 0.36593737231924195)], [(0.91193453416703718, 0.36651914291880922)])>)>]"

# Set theme
gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita'
gsettings set org.gnome.shell.extensions.user-theme name 'Adwaita'
gsettings set org.gnome.desktop.interface icon-theme 'Papirus'
gsettings set org.gnome.desktop.interface enable-animations true
gsettings set org.gnome.desktop.interface clock-show-date true
gsettings set org.gnome.desktop.interface clock-show-seconds false
gsettings set org.gnome.desktop.wm.preferences titlebar-font 'Noto Sans Bold 10'
gsettings set org.gnome.desktop.interface document-font-name 'Sans 11'
gsettings set org.gnome.desktop.interface font-name 'Noto Sans 10'
gsettings set org.gnome.desktop.interface monospace-font-name 'Noto Sans Mono 10'

# Set favorite apps
gsettings set org.gnome.shell favorite-apps "['firefox.desktop', 'pidgin.desktop', 'skypeforlinux.desktop', 'vlc.desktop', 'spotify.desktop', 'evince.desktop', 'org.gnome.Nautilus.desktop', 'org.gnome.Terminal.desktop', 'idea.desktop']"

# Minimize and close buttons
gsettings set org.gnome.desktop.wm.preferences button-layout 'appmenu:minimize,maximize,close'

# Locale
gsettings set org.gnome.system.locale region 'pl_PL.UTF-8'
gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'pl')]"

# Night colors
gsettings set org.gnome.settings-daemon.plugins.color night-light-enabled true

# Nautilus
gsettings set org.gnome.nautilus.icon-view default-zoom-level 'standard'
gsettings set org.gnome.nautilus.list-view default-column-order "['name', 'size', 'type', 'owner', 'group', 'permissions', 'mime_type', 'where', 'date_modified', 'date_modified_with_time', 'date_accessed']"
gsettings set org.gnome.nautilus.list-view default-visible-columns "['name', 'size', 'type', 'date_modified']"
gsettings set org.gnome.nautilus.list-view default-zoom-level 'small'
gsettings set org.gnome.nautilus.preferences default-folder-viewer 'icon-view'
gsettings set org.gnome.nautilus.preferences search-filter-time-type 'last_modified'
gsettings set org.gnome.nautilus.preferences search-view 'list-view'

# Terminal
#profile=$(gsettings get org.gnome.Terminal.ProfilesList default)
#profile=${profile:1:-1} # remove leading and trailing single quotes

#gsettings set "org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$profile/" background-color 'rgb(46,52,54)'
#gsettings set "org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$profile/" bold-color 'rgb(78,154,6)'
#gsettings set "org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$profile/" bold-color-same-as-fg true
#gsettings set "org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$profile/" font 'Ubuntu Mono 13'
#gsettings set "org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$profile/" foreground-color 'rgb(255,255,255)'
#gsettings set "org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$profile/" highlight-colors-set true
#gsettings set "org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$profile/" highlight-foreground-color 'rgb(0,0,0)'
#gsettings set "org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$profile/" highlight-background-color 'rgb(255,255,255)'
#gsettings set "org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$profile/" use-theme-colors false
#gsettings set "org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$profile/" use-system-font false
#gsettings set "org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$profile/" palette "['rgb(0,0,0)', 'rgb(204,0,0)', 'rgb(78,154,6)', 'rgb(196,160,0)', 'rgb(52,101,164)', 'rgb(117,80,123)', 'rgb(6,152,154)', 'rgb(211,215,207)', 'rgb(85,87,83)', 'rgb(239,41,41)', 'rgb(138,226,52)', 'rgb(252,233,79)', 'rgb(114,159,207)', 'rgb(173,127,168)', 'rgb(52,226,226)', 'rgb(238,238,236)']"
#gsettings set "org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$profile/" visible-name 'hubert'
#gsettings set "org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$profile/" scrollback-unlimited true

# Disable searching of potential software. 
#gsettings set org.gnome.desktop.search-providers disabled \[\'org.gnome.Software.desktop\'\]

# Configure touchpad
gsettings set org.gnome.desktop.peripherals.touchpad tap-to-click true
#gsettings set org.gnome.desktop.peripherals.touchpad natural-scroll true
#gsettings set org.gnome.desktop.peripherals.touchpad scroll-method 'two-finger-scrolling'

# Sounds
gsettings set org.gnome.desktop.sound event-sounds false

# Sort folders first
gsettings set org.gtk.Settings.FileChooser sort-directories-first true