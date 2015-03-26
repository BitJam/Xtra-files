#!/bin/bash
# File Name: controlcenter.sh
# Purpose: all-in-one control centre for antiX
# Authors: OU812 and minor modifications by anticapitalista
# Latest Change: 20 August 2008
# Latest Change: 11 January 2009 and renamed antixcc.sh
# Latest Change: 15 August 2009 some apps and labels altered.
# Latest Change: 09 March 2012 by anticapitalista. Added Live section.
# Latest Change: 22 March 2012 by anticapitalista. Added jwm config options and edited admin options.
# Latest Change: 18 April 2012 by anticapitalista. mountbox-antix opens as user not root.
# Latest Change: 06 October 2012 by anticapitalista. Function for ICONS. New icon theme.
# Latest Change: 26 October 2012 by anticapitalista. Includes gksudo and ktsuss.
# Latest Change: 12 May 2013 by anticapitalista. Let user set default apps.
# Latest Change: 05 March 2015 by BitJam: Add alsa-set-card, edit excludes, edit bootloader.  Fix indentation.
#                                         Hide live tab on non-live systems.  Use echo instead of gettext.
#                                         Remove unneeded doublequotes between tags.  Use $(...) instead of `...`.
# Acknowledgements: Original script by KDulcimer of TinyMe. http://tinyme.mypclinuxos.com
##################################################################################################################

TEXTDOMAINDIR=/usr/share/locale
TEXTDOMAIN=antixcc.sh
# Options
ICONS=/usr/share/icons/antiX
ED1=geany
TERM=urxvt

if [ $UID -ne 0 ]; then
    echo "Relaunching as root ..."
    exec gksu -k -- "$0"
fi

if [ "$USER" = root ]; then 
    yad --center --on-top --width=680 --title $"Error" \
        --text "\n"$"This program must be run first as a normal user""\n"
    exit 3
fi

home=$(getent passwd $USER | cut -d: -f6)
root_home=$(getent passwd root | cut -d: -f6)

AS_USER="su -c"
AS_ROOT="env HOME=$root_home"
ED_ROOT="$AS_ROOT $ED1"
TERM_ROOT="$AS_ROOT $TERM"

export XAUTHORITY=$home/.Xauthority

Desktop=$"Desktop" System=$"System" Network=$"Network" Session=$"Session"
Live=$"Live" Disks=$"Disks" Hardware=$"Hardware"

# Edit syslinux.cfg if the device it is on is mounted read-write
grep -q " /live/boot-dev .*\<rw\>" /proc/mounts \
    && edit_bootloader=$(cat <<Edit_Bootloader
    <hbox>
      <button>
        <input file>$ICONS/preferences-desktop.png</input>
        <action>$ED_ROOT /live/boot-dev/boot/syslinux/syslinux.cfg /live/boot-dev/boot/syslinux/gfxboot.cfg &</action>
      </button>
      <text use-markup="true" width-chars="25">
        <label>$(echo $"Edit Bootloader menu")</label>
      </text>
    </hbox>
Edit_Bootloader
)

excludes_dir=/usr/local/share/excludes
test -d $excludes_dir && edit_excludes=$(cat <<Edit_Excludes
    <hbox>
      <button>
        <input file>$ICONS/preferences-desktop.png</input>
        <action>$ED_ROOT $excludes_dir/*.list &</action>
      </button>
      <text use-markup="true" width-chars="25">
        <label>$(echo $"Edit Exclude files")</label>
      </text>
    </hbox>
Edit_Excludes
)

[ -e /live/config/save-persist -o -e /live/config/persist-save.conf]  && persist_save=$(cat <<Persist_Save
    <hbox>
      <button>
        <input file>$ICONS/palimpsest.png</input>
        <action>$AS_ROOT persist-save &</action>
      </button>
      <text use-markup="true" width-chars="25">
        <label>$(echo $"Save root persistence")</label>
      </text>
    </hbox>
Persist_Save
)

[ -e /live/config/remasterable -o -e /live/config/remaster-live.conf ] && live_remaster=$(cat <<Live_Remaster
    <hbox>
      <button>
        <input file>$ICONS/preferences-desktop.png</input>
        <action>$AS_ROOT remaster-live &</action>
      </button>
      <text use-markup="true" width-chars="25">
        <label>$(echo $"Remaster")</label>
      </text>
    </hbox>
Live_Remaster
)

live_tab=$(cat <<Live_Tab
<vbox> <frame> <hbox>
  <vbox>
    <hbox>
      <button>
        <input file>$ICONS/palimpsest.png</input>
        <action>$AS_ROOT persist-config &</action>
      </button>
      <text use-markup="true" width-chars="25">
        <label>$(echo $"Configure live persistence")</label>
      </text>
    </hbox>
    <hbox>
      <button>
        <input file>$ICONS/preferences-desktop.png</input>
        <action>$AS_ROOT persist-makefs &</action>
      </button>
      <text use-markup="true" width-chars="25">
        <label>$(echo $"Set up live persistence")</label>
      </text>
    </hbox>
$edit_excludes
  </vbox>
  <vbox>
$persist_save
$live_remaster
$edit_bootloader
  </vbox>
</hbox> </frame> </vbox>
Live_Tab
)

# If we are on a live system then ...
if grep -q " /live/aufs aufs" /proc/mounts; then
    tab_labels="$Desktop|$System|$Network|$Session|$Live|$Disks|$Hardware"

else
    tab_labels="$Desktop|$System|$Network|$Session|$Disks|$Hardware"
    live_tab=
fi

export ControlCenter=$(cat <<End_of_Text
<window title="antiX Control Center" icon="gnome-control-center" window-position="1">
  <vbox>
<notebook tab-pos="0" labels="$tab_labels">
<vbox> <frame> <hbox>
  <vbox>

    <hbox>
      <button>
        <input file>$ICONS/preferences-desktop-wallpaper.png</input>
        <action>$AS_USER "wallpaper.py" - $USER &</action>
      </button>
      <text use-markup="true" width-chars="25">
        <label>$(echo $"Choose Wallpaper")</label>
      </text>
    </hbox>

    <hbox>
      <button>
        <input file>$ICONS/desktop-effects.png</input>
        <action>$AS_USER "$ED1 $home/.fluxbox/overlay $home/.fluxbox/keys $home/.fluxbox/init $home/.fluxbox/startup $home/.fluxbox/apps $home/.fluxbox/menu" - $USER &</action>
      </button>
      <text use-markup="true" width-chars="25">
        <label>$(echo $"Edit Fluxbox Settings")</label>
      </text>
    </hbox>

    <hbox>
      <button>
        <input file>$ICONS/utilities-system-monitor.png</input>
        <action>$AS_USER "$ED1 $home/.conkyrc" - $USER &</action>
      </button>
      <text use-markup="true" width-chars="25">
        <label>$(echo $"Edit System Monitor")</label>
      </text>
    </hbox>
  </vbox>

  <vbox>
    <hbox>
      <button>
        <input file>$ICONS/preferences-desktop-theme.png</input>
        <action>$AS_USER "lxappearance" - $USER &</action>
      </button>
      <text use-markup="true" width-chars="25">
        <label>$(echo $"Change Gtk2 and Icon Themes")</label>
      </text>
    </hbox>

    <hbox>
      <button>
        <input file>$ICONS/desktop-effects.png</input>
        <action>$AS_USER "$ED1 $home/.icewm/winoptions $home/.icewm/preferences $home/.icewm/keys $home/.icewm/startup $home/.icewm/toolbar $home/.icewm/menu" - $USER &</action>
      </button>
      <text use-markup="true" width-chars="25">
        <label>$(echo $"Edit IceWM Settings")</label>
      </text>
    </hbox>

    <hbox>
      <button>
        <input file>$ICONS/desktop-effects.png</input>
        <action>$AS_USER "$ED1 $home/.jwm/preferences $home/.jwm/keys $home/.jwm/tray $home/.jwm/startup $home/.jwmrc $home/.jwm/menu" - $USER &</action>
      </button>
      <text use-markup="true" width-chars="25">
        <label>$(echo $"Edit jwm Settings")</label>
      </text>
    </hbox>

  </vbox>
</hbox> </frame> </vbox>
<vbox> <frame> <hbox>
  <vbox>

    <hbox>
      <button>
        <input file>$ICONS/synaptic.png</input>
        <action>$AS_ROOT synaptic &</action>
      </button>
      <text use-markup="true" width-chars="25">
        <label>$(echo $"Manage Packages")</label>
      </text>
    </hbox>

    <hbox>
      <button>
        <input file>$ICONS/applications-system.png</input>
        <action>$AS_ROOT antix-system.sh &</action>
      </button>
      <text use-markup="true" width-chars="25">
        <label>$(echo $"Configure System")</label>
      </text>
    </hbox>
    <hbox>
      <button>
        <input file>$ICONS/gnome-settings-default-applications.png</input>
        <action>$TERM_ROOT -e sysv-rc-conf &</action>
      </button>
      <text use-markup="true" width-chars="25">
        <label>$(echo $"Choose Startup Services")</label>
      </text>
    </hbox>
  </vbox>

  <vbox>
    <hbox>
      <button>
        <input file>$ICONS/config-users.png</input>
        <action>$AS_ROOT user-management &</action>
      </button>
      <text use-markup="true" width-chars="25">
        <label>$(echo $"Manage Users")</label>
      </text>
    </hbox>

    <hbox>
      <button>
        <input file>$ICONS/preferences-desktop.png</input>
        <action>$ED_ROOT /etc/fstab /etc/default/keyboard /boot/grub/menu.lst /etc/slim.conf /etc/apt/sources.list.d/various.list /etc/apt/sources.list.d/antix.list /etc/apt/sources.list.d/debian.list &</action>
      </button>
      <text use-markup="true" width-chars="25">
        <label>$(echo $"Edit Config Files")</label>
      </text>
    </hbox>

    <hbox>
      <button>
        <input file>$ICONS/time-admin.png</input>
        <action>$TERM_ROOT -e "dpkg-reconfigure tzdata" &</action>
      </button>
      <text use-markup="true" width-chars="25">
        <label>$(echo $"Set Date and Time")</label>
      </text>
    </hbox>
  </vbox>

</hbox> </frame> </vbox>
<vbox> <frame> <hbox>

  <vbox>
    <hbox>
      <button>
        <input file>$ICONS/network-wired.png</input>
        <action>$TERM_ROOT -e ceni &</action>
      </button>
      <text use-markup="true" width-chars="25">
        <label>$(echo $"Network Interfaces (ceni)")</label>
      </text>
    </hbox>

    <hbox>
      <button>
        <input file>$ICONS/network-wired.png</input>
        <action>$AS_ROOT umts-panel &</action>
      </button>
      <text use-markup="true" width-chars="25">
        <label>$(echo $"Configure GPRS/UMTS Connection")</label>
      </text>
    </hbox>

    <hbox>
      <button>
        <input file>$ICONS/network-wireless.png</input>
        <action>$AS_USER "wicd-gtk" - $USER &</action>
      </button>
      <text use-markup="true" width-chars="25">
        <label>$(echo $"Connect Wirelessly (wicd)")</label>
      </text>
    </hbox>
  </vbox>

  <vbox>
    <hbox>
      <button>
        <input file>$ICONS/network-wireless.png</input>
        <action>$AS_ROOT rutilt &</action>
      </button>
      <text use-markup="true" width-chars="25">
        <label>$(echo $"Wireless (rutilt)")</label>
      </text>
    </hbox>

    <hbox>
      <button>
        <input file>$ICONS/network-wired.png</input>
        <action>$AS_USER gnome-ppp - $USER&</action>
      </button>
      <text use-markup="true" width-chars="25">
        <label>$(echo $"Configure Dial-Up Connection")</label>
      </text>
    </hbox>

    <hbox>
      <button>
        <input file>$ICONS/preferences-system-firewall.png</input>
        <action>$AS_ROOT gufw &</action>
      </button>
      <text use-markup="true" width-chars="25">
        <label>$(echo $"Manage Firewall")</label>
      </text>
    </hbox>
  </vbox>
</hbox> </frame></vbox>
<vbox> <frame> <hbox>
  <vbox>
    <hbox>
      <button>
        <input file>$ICONS/keyboard.png</input>
        <action>$AS_USER "antixcckeyboard.sh" - $USER &</action>
      </button>
      <text use-markup="true" width-chars="25">
        <label>$(echo $"Change Keyboard Layout")</label>
      </text>
    </hbox>
    <hbox>
      <button>
        <input file>$ICONS/preferences-desktop-wallpaper.png</input>
        <action>$AS_ROOT antixccslim.sh</action>
      </button>
      <text use-markup="true" width-chars="25">
        <label>$(echo $"Change Slim Background")</label>
      </text>
    </hbox>
    <hbox>
      <button>
        <input file>$ICONS/video-display.png</input>
        <action>$AS_USER arandr - $USER&</action>
      </button>
      <text use-markup="true" width-chars="25">
        <label>$(echo $"Set Screen Resolution")</label>
      </text>
    </hbox>
    <hbox>
      <button>
        <input file>$ICONS/computer.png</input>
        <action>$ED_ROOT /etc/desktop-session/desktop-session.conf /etc/desktop-session/startup /etc/desktop-session/file_compare /etc/desktop-session/desktop-defaults.conf &</action>
      </button>
      <text use-markup="true" width-chars="25">
        <label>$(echo $"Global desktop-session configuration")</label>
      </text>
    </hbox>
  </vbox>
  <vbox>
    <hbox>
      <button>
        <input file>$ICONS/gdm-setup.png</input>
        <action>$AS_ROOT slim-login &</action>
      </button>
      <text use-markup="true" width-chars="25">
        <label>$(echo $"Set auto-login")</label>
      </text>
    </hbox>
    <hbox>
      <button>
        <input file>$ICONS/video-display.png</input>
        <action>$AS_USER "set-screen-blank" - $USER&</action>
      </button>
      <text use-markup="true" width-chars="25">
        <label>$(echo $"Set Screen Blanking")</label>
      </text>
    </hbox>
    <hbox>
      <button>
        <input file>$ICONS/computer.png</input>
        <action>$AS_USER "geany $home/.desktop-session/desktop-session.conf $home/.desktop-session/startup $home/.desktop-session/file_compare $home/.desktop-session/desktop-defaults.conf" - $USER &</action>
      </button>
      <text use-markup="true" width-chars="25">
        <label>$(echo $"User desktop-session configuration")</label>
      </text>
    </hbox>
  </vbox>
</hbox> </frame> </vbox>
$live_tab
<vbox> <frame> <hbox>
  <vbox>
    <hbox>
      <button>
        <input file>$ICONS/gparted.png</input>
        <action>$AS_ROOT gparted &</action>
      </button>
      <text use-markup="true" width-chars="25">
        <label>$(echo $"Partition a Drive")</label>
      </text>
    </hbox>
    <hbox>
      <button>
        <input file>$ICONS/drive-removable-media.png</input>
        <action>$AS_ROOT mountbox &</action>
      </button>
      <text use-markup="true" width-chars="25">
        <label>$(echo $"Mount Connected Devices")</label>
      </text>
    </hbox>
    <hbox>
      <button>
        <input file>$ICONS/file-roller.png</input>
        <action>$AS_ROOT luckybackup &</action>
      </button>
      <text use-markup="true" width-chars="25">
        <label>$(echo $"Backup Your System")</label>
      </text>
    </hbox>
  </vbox>
  <vbox>
    <hbox>
      <button>
        <input file>$ICONS/drive-removable-media-usb.png</input>
        <action>$AS_ROOT antix2usb.py &</action>
      </button>
      <text use-markup="true" width-chars="25">
        <label>$(echo $"antiX2usb")</label>
      </text>
    </hbox>
    <hbox>
      <button>
        <input file>$ICONS/drive-harddisk-system.png</input>
        <action>$TERM_ROOT -e partimage &</action>
      </button>
      <text use-markup="true" width-chars="25">
        <label>$(echo $"Image a Partition")</label>
      </text>
    </hbox>
    <hbox>
      <button>
        <input file>$ICONS/preferences-desktop-remote-desktop.png</input>
        <action>$AS_ROOT grsync &</action>
      </button>
      <text use-markup="true" width-chars="25">
        <label>$(echo $"Synchronize Directories")</label>
      </text>
    </hbox>
  </vbox>
</hbox> </frame> </vbox>
<vbox> <frame> <hbox>
  <vbox>
    <hbox>
      <button>
        <input file>$ICONS/computer.png</input>
        <action>$AS_USER "hardinfo" - $USER &</action>
      </button>
      <text use-markup="true" width-chars="25">
        <label>$(echo $"System Information")</label>
      </text>
    </hbox>
    <hbox>
      <button>
        <input file>$ICONS/printer.png</input>
        <action>$AS_ROOT system-config-printer &</action>
      </button>
      <text use-markup="true" width-chars="25">
        <label>$(echo $"Setup a Printer")</label>
      </text>
    </hbox>
    <hbox>
      <button>
        <input file>$ICONS/computer.png</input>
        <action>$AS_USER "inxi-gui" - $USER &</action>
      </button>
      <text use-markup="true" width-chars="25">
        <label>$(echo $"PC Information")</label>
      </text>
    </hbox>
    <hbox>
      <button>
        <input file>$ICONS/input-mouse.png</input>
        <action>$AS_USER "antixccmouse.sh" - $USER &</action>
      </button>
      <text use-markup="true" width-chars="25">
        <label>$(echo $"Configure Mouse")</label>
      </text>
    </hbox>

  </vbox>
  <vbox>
    <hbox>
      <button>
        <input file>$ICONS/preferences-desktop-sound.png</input>
        <action>$AS_USER "$TERM -e speaker-test --channels 2 --test wav --nloops 3" - $USER &</action>
      </button>
      <text use-markup="true" width-chars="25">
        <label>$(echo $"Test Sound")</label>
      </text>
    </hbox>
    <hbox>
      <button>
        <input file>$ICONS/preferences-desktop-sound.png</input>
        <action>$AS_USER "$TERM -e alsamixer" - $USER &</action>
      </button>
      <text use-markup="true" width-chars="25">
        <label>$(echo $"Adjust Mixer")</label>
      </text>
    </hbox>
    <hbox>
      <button>
        <input file>$ICONS/preferences-desktop-sound.png</input>
        <action>$AS_USER "alsa-set-default-card" - $DEMO &</action>
      </button>
      <text use-markup="true" width-chars="25">
        <label>$(echo $"Set default sound card")</label>
      </text>
    </hbox>

  </vbox>
</hbox> </frame> </vbox>
</notebook>
</vbox>
</window>
End_of_Text
)

#echo "$ControlCenter"

gtkdialog --program=ControlCenter
#unset ControlCenter
