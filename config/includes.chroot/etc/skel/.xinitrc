#!/bin/sh
#gnome-keyring-daemon -r -d &
dbus-update-activation-environment --all
gnome-keyring-daemon --start --components=secrets
#nm-applet &
#connman-ui-gtk &
xscreensaver -no-splash &
unclutter &
numlockx &
lxpanel &
xfce4-clipman &
redshift-gtk &
exec openbox-session