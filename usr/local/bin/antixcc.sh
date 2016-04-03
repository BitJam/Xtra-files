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
#################################################################################################################################################

TEXTDOMAINDIR=/usr/share/locale
TEXTDOMAIN=antixcc.sh
# Options
ICONS=/usr/share/icons/antiX

EDITOR="geany -i"

Desktop=$"Desktop" System=$"System" Network=$"Network" Session=$"Session"
Live=$"Live" Disks=$"Disks" Hardware=$"Hardware" 

[ -d $HOME/.fluxbox -a -e /usr/share/xsessions/fluxbox.desktop ] \
    && edit_fluxbox=$(cat <<Edit_Fluxbox
    <hbox>
      <button>
        <input file>$ICONS/cs-desktop-effects.png</input>
        <action>$EDITOR $HOME/.fluxbox/overlay $HOME/.fluxbox/keys $HOME/.fluxbox/init $HOME/.fluxbox/startup $HOME/.fluxbox/apps $HOME/.fluxbox/menu&</action>
      </button>
      <text use-markup="true" width-chars="28">
        <label>$(echo $"Edit Fluxbox Settings")</label>
      </text>
    </hbox>
Edit_Fluxbox
)

[ -d $HOME/.icewm -a -e /usr/share/xsessions/IceWM.desktop ] \
    && edit_icewm=$(cat <<Edit_Icewm
    <hbox>
      <button>
        <input file>$ICONS/cs-desktop-effects.png</input>
        <action>$EDITOR $HOME/.icewm/winoptions $HOME/.icewm/preferences $HOME/.icewm/keys $HOME/.icewm/startup $HOME/.icewm/toolbar $HOME/.icewm/menu&</action>
      </button>
      <text use-markup="true" width-chars="28">
        <label>$(echo $"Edit IceWM Settings")</label>
      </text>
    </hbox>
Edit_Icewm
)

[ -d $HOME/.jwm -a -e /usr/share/xsessions/Jwm.desktop ] \
    && edit_jwm=$(cat <<Edit_Jwm
    <hbox>
      <button>
        <input file>$ICONS/cs-desktop-effects.png</input>
        <action>$EDITOR $HOME/.jwm/preferences $HOME/.jwm/keys $HOME/.jwm/tray $HOME/.jwm/startup $HOME/.jwmrc $HOME/.jwm/menu</action>
      </button>
      <text use-markup="true" width-chars="28">
        <label>$(echo $"Edit jwm Settings")</label>
      </text>
    </hbox>
Edit_Jwm
)


# Edit syslinux.cfg if the device it is own is mounted read-write
grep -q " /live/boot-dev .*\<rw\>" /proc/mounts \
    && edit_bootloader=$(cat <<Edit_Bootloader
    <hbox>
      <button>
        <input file>$ICONS/preferences-desktop.png</input>
        <action>gksu "$EDITOR /live/boot-dev/boot/syslinux/syslinux.cfg /live/boot-dev/boot/syslinux/gfxboot.cfg" &</action>
      </button>
      <text use-markup="true" width-chars="28">
        <label>$(echo $"Edit Bootloader menu")</label>
      </text>
    </hbox>
Edit_Bootloader
)

excludes_dir=/usr/local/share/excludes
test -d $excludes_dir && edit_excludes=$(cat <<Edit_Excludes
    <hbox>
      <button>
        <input file>$ICONS/remastersys.png</input>
        <action>gksu $EDITOR $excludes_dir/*.list &</action>
      </button>
      <text use-markup="true" width-chars="28">
        <label>$(echo $"Edit Exclude files")</label>
      </text>
    </hbox>
Edit_Excludes
)

[ -e /live/config/save-persist -o -e /live/config/persist-save.conf ]  && persist_save=$(cat <<Persist_Save
    <hbox>
      <button>
        <input file>$ICONS/palimpsest.png</input>
        <action>gksu persist-save &</action>
      </button>
      <text use-markup="true" width-chars="28">
        <label>$(echo $"Save root persistence")</label>
      </text>
    </hbox>
Persist_Save
)

[ -e /etc/live/config/remasterable -o -e /live/config/remasterable ] && live_remaster=$(cat <<Live_Remaster
    <hbox>
      <button>
        <input file>$ICONS/preferences-desktop.png</input>
        <action>gksu remaster-live &</action>
      </button>
      <text use-markup="true" width-chars="28">
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
        <input file>$ICONS/remastersys.png</input>
        <action>gksu persist-config &</action>
      </button>
      <text use-markup="true" width-chars="28">
        <label>$(echo $"Configure live persistence")</label>
      </text>
    </hbox>
$edit_bootloader
$persist_save
  </vbox>
  <vbox>
    <hbox>
      <button>
        <input file>$ICONS/palimpsest.png</input>
        <action>gksu persist-makefs &</action>
      </button>
      <text use-markup="true" width-chars="28">
        <label>$(echo $"Set up live persistence")</label>
      </text>
    </hbox>
$edit_excludes
$live_remaster
  </vbox>
</hbox> </frame> </vbox>
Live_Tab
)

# If we are on a live system then ...
if grep -q " /live/aufs aufs" /proc/mounts; then
    tab_labels="$Desktop|$System|$Network|$Session|$Live|$Disks|$Hardware|$CLI|$Tools"

else
    tab_labels="$Desktop|$System|$Network|$Session|$Disks|$Hardware|$CLI|$Tools"
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
        <action>wallpaper.py &</action>
      </button>
      <text use-markup="true" width-chars="28">
        <label>$(echo $"Choose Wallpaper")</label>
      </text>
    </hbox>
$edit_fluxbox
$edit_jwm
    <hbox>
      <button>
        <input file>$ICONS/utilities-system-monitor.png</input>
        <action>desktop-defaults-run -te $HOME/.conkyrc  &</action>
      </button>
      <text use-markup="true" width-chars="28">
        <label>$(echo $"Edit System Monitor(conky)")</label>
      </text>
    </hbox>
  </vbox>

  <vbox>
    <hbox>
      <button>
        <input file>$ICONS/preferences-desktop-theme.png</input>
        <action>lxappearance &</action>
      </button>
      <text use-markup="true" width-chars="28">
        <label>$(echo $"Change Gtk2 and Icon Themes")</label>
      </text>
    </hbox>
$edit_icewm
    <hbox>
      <button>
        <input file>$ICONS/applications-system.png</input>
        <action>desktop-defaults-set &</action>
      </button>
      <text use-markup="true" width-chars="28">
        <label>$(echo $"Preferred Applications")</label>
      </text>
    </hbox>
     <hbox>
      <button>
        <input file>$ICONS/menu_manager.png</input>
        <action>sudo menu_manager.sh &</action>
      </button>
      <text use-markup="true" width-chars="28">
        <label>$(echo $"Edit menus")</label>
      </text>
    </hbox>
  </vbox>
</hbox> </frame> </vbox>
<vbox> <frame> <hbox>
  <vbox>

    <hbox>
      <button>
        <input file>$ICONS/synaptic.png</input>
        <action>gksu synaptic &</action>
      </button>
      <text use-markup="true" width-chars="28">
        <label>$(echo $"Manage Packages")</label>
      </text>
    </hbox>

    <hbox>
      <button>
        <input file>$ICONS/applications-system.png</input>
        <action>gksu antix-system.sh &</action>
      </button>
      <text use-markup="true" width-chars="28">
        <label>$(echo $"Configure System")</label>
      </text>
    </hbox>
    <hbox>
      <button>
        <input file>$ICONS/synaptic.png</input>
        <action>gksu install-meta &</action>
      </button>
      <text use-markup="true" width-chars="28">
        <label>$(echo $"Meta Package Installer")</label>
      </text>
    </hbox>
    <hbox>
      <button>
        <input file>$ICONS/gnome-settings-default-applications.png</input>
        <action>desktop-defaults-run -t sudo sysv-rc-conf &</action>
      </button>
      <text use-markup="true" width-chars="28">
        <label>$(echo $"Choose Startup Services")</label>
      </text>
    </hbox>
  </vbox>

  <vbox>
    <hbox>
      <button>
        <input file>$ICONS/config-users.png</input>
        <action>gksu user-management &</action>
      </button>
      <text use-markup="true" width-chars="28">
        <label>$(echo $"Manage Users")</label>
      </text>
    </hbox>

    <hbox>
      <button>
        <input file>$ICONS/preferences-desktop.png</input>
        <action>gksu $EDITOR /etc/fstab /etc/default/keyboard /etc/grub.d/* /etc/slim.conf /etc/apt/sources.list.d/*.list &</action>
      </button>
      <text use-markup="true" width-chars="28">
        <label>$(echo $"Edit Config Files")</label>
      </text>
    </hbox>
    
    <hbox>
      <button>
        <input file>$ICONS/hwinfo.png</input>
        <action>hardinfo &</action>
      </button>
      <text use-markup="true" width-chars="28">
        <label>$(echo $"System Information")</label>
      </text>
    </hbox>
    <hbox>
      <button>
        <input file>$ICONS/time-admin.png</input>
        <action>desktop-defaults-run -t sudo "dpkg-reconfigure tzdata" &</action>
      </button>
      <text use-markup="true" width-chars="28">
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
        <action>desktop-defaults-run -t sudo ceni &</action>
      </button>
      <text use-markup="true" width-chars="28">
        <label>$(echo $"Network Interfaces (ceni)")</label>
      </text>
    </hbox>

    <hbox>
      <button>
        <input file>$ICONS/network-wired.png</input>
        <action>umts-panel &</action>
      </button>
      <text use-markup="true" width-chars="28">
        <label>$(echo $"Configure GPRS/UMTS")</label>
      </text>
    </hbox>

    <hbox>
      <button>
        <input file>$ICONS/nm-device-wireless.png</input>
        <action>wicd-gtk &</action>
      </button>
      <text use-markup="true" width-chars="28">
        <label>$(echo $"Connect Wirelessly (wicd)")</label>
      </text>
    </hbox>
   
    <hbox>
      <button>
        <input file>$ICONS/connectshares-config.png</input>
        <action>connectshares-config &</action>
      </button>
      <text use-markup="true" width-chars="28">
        <label>$(echo $"Configure Connectshares")</label>
      </text>
    </hbox>
  </vbox>
  <vbox>
    <hbox>
      <button>
        <input file>$ICONS/internet-telephony.png</input>
        <action>gnome-ppp &</action>
      </button>
      <text use-markup="true" width-chars="28">
        <label>$(echo $"Configure Dial-Up")</label>
      </text>
    </hbox>
    <hbox>
      <button>
        <input file>$ICONS/nm-device-wireless.png</input>
        <action>/usr/sbin/wpa_gui &</action>
      </button>
      <text use-markup="true" width-chars="28">
        <label>$(echo $"Configure wpa_supplicant")</label>
      </text>
    </hbox>
    <hbox>
      <button>
        <input file>$ICONS/firewall.png</input>
        <action>gksu gufw &</action>
      </button>
      <text use-markup="true" width-chars="28">
        <label>$(echo $"Manage Firewall")</label>
      </text>
    </hbox>
    <hbox>
      <button>
        <input file>$ICONS/advert-block.png</input>
        <action>gksu block-advert.sh &</action>
      </button>
      <text use-markup="true" width-chars="28">
        <label>$(echo $"Adblock")</label>
      </text>
    </hbox>
  </vbox>
</hbox> </frame></vbox>
<vbox> <frame> <hbox>
  <vbox>
    <hbox>
      <button>
        <input file>$ICONS/keyboard.png</input>
        <action>antixcckeyboard.sh &</action>
      </button>
      <text use-markup="true" width-chars="28">
        <label>$(echo $"Change Keyboard Layout")</label>
      </text>
    </hbox>
    <hbox>
      <button>
        <input file>$ICONS/preferences-desktop-wallpaper.png</input>
        <action>gksu antixccslim.sh</action>
      </button>
      <text use-markup="true" width-chars="28">
        <label>$(echo $"Change Slim Background")</label>
      </text>
    </hbox>
    <hbox>
      <button>
        <input file>$ICONS/video-display.png</input>
        <action>gksu arandr &</action>
      </button>
      <text use-markup="true" width-chars="28">
        <label>$(echo $"Set Screen Resolution")</label>
      </text>
    </hbox>
    <hbox>
      <button>
        <input file>$ICONS/preferences-desktop.png</input>
        <action>gksu $EDITOR /etc/desktop-session/*.conf /etc/desktop-session/startup &</action>
      </button>
      <text use-markup="true" width-chars="28">
        <label>$(echo $"Global Desktop-Session")</label>
      </text>
    </hbox>
  </vbox>
  <vbox>
    <hbox>
      <button>
        <input file>$ICONS/gnome-session.png</input>
        <action>gksu-properties &</action>
      </button>
      <text use-markup="true" width-chars="28">
        <label>$(echo $"Password Prompt(su/sudo)")</label>
      </text>
    </hbox>
    <hbox>
      <button>
        <input file>$ICONS/preferences-system-login.png</input>
        <action>gksu slim-login &</action>
      </button>
      <text use-markup="true" width-chars="28">
        <label>$(echo $"Set auto-login")</label>
      </text>
    </hbox>
    <hbox>
      <button>
        <input file>$ICONS/screensaver.png</input>
        <action>set-screen-blank &</action>
      </button>
      <text use-markup="true" width-chars="28">
        <label>$(echo $"Set Screen Blanking")</label>
      </text>
    </hbox>
    <hbox>
      <button>
        <input file>$ICONS/config-users.png</input>
        <action>$EDITOR $HOME/.desktop-session/*.conf $HOME/.desktop-session/startup &</action>
      </button>
      <text use-markup="true" width-chars="28">
        <label>$(echo $"User Desktop-Session")</label>
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
        <action>gksu gparted &</action>
      </button>
      <text use-markup="true" width-chars="28">
        <label>$(echo $"Partition a Drive")</label>
      </text>
    </hbox>
    <hbox>
      <button>
        <input file>$ICONS/mountbox.png</input>
        <action>mountbox &</action>
      </button>
      <text use-markup="true" width-chars="28">
        <label>$(echo $"Mount Connected Devices")</label>
      </text>
    </hbox>
    <hbox>
      <button>
        <input file>$ICONS/luckybackup.png</input>
        <action>gksu luckybackup &</action>
      </button>
      <text use-markup="true" width-chars="28">
        <label>$(echo $"Backup Your System")</label>
      </text>
    </hbox>
    <hbox>
      <button>
        <input file>$ICONS/usb-creator.png</input>
        <action>gksu unetbootin &</action>
      </button>
      <text use-markup="true" width-chars="28">
        <label>$(echo $"UNetbootin")</label>
      </text>
    </hbox>
  </vbox>
  <vbox>
    <hbox>
      <button>
        <input file>$ICONS/usb-creator.png</input>
        <action>gksu antix2usb.py &</action>
      </button>
      <text use-markup="true" width-chars="28">
        <label>$(echo $"antiX2usb")</label>
      </text>
    </hbox>
    <hbox>
      <button>
        <input file>$ICONS/drive-harddisk-system.png</input>
        <action>desktop-defaults-run -t sudo partimage &</action>
      </button>
      <text use-markup="true" width-chars="28">
        <label>$(echo $"Image a Partition")</label>
      </text>
    </hbox>
    <hbox>
      <button>
        <input file>$ICONS/grsync.png</input>
        <action>grsync &</action>
      </button>
      <text use-markup="true" width-chars="28">
        <label>$(echo $"Synchronize Directories")</label>
      </text>
    </hbox>
  </vbox>
</hbox> </frame> </vbox>
<vbox> <frame> <hbox>
  <vbox>
    <hbox>
      <button>
        <input file>$ICONS/printer.png</input>
        <action>system-config-printer &</action>
      </button>
      <text use-markup="true" width-chars="28">
        <label>$(echo $"Setup a Printer")</label>
      </text>
    </hbox>
    <hbox>
      <button>
        <input file>$ICONS/computer.png</input>
        <action>inxi-gui &</action>
      </button>
      <text use-markup="true" width-chars="28">
        <label>$(echo $"PC Information")</label>
      </text>
    </hbox>
    <hbox>
      <button>
        <input file>$ICONS/input-mouse.png</input>
        <action>ds-mouse &</action>
      </button>
      <text use-markup="true" width-chars="28">
        <label>$(echo $"Configure Mouse")</label>
      </text>
    </hbox>

  </vbox>
  <vbox>
    <hbox>
      <button>
        <input file>$ICONS/audacity.png</input>
        <action>alsa-set-default-card &</action>
      </button>
      <text use-markup="true" width-chars="28">
        <label>$(echo $"Set Default Sound Card")</label>
      </text>
    </hbox>
    <hbox>
      <button>
        <input file>$ICONS/preferences-desktop-sound.png</input>
        <action>urxvt -e speaker-test --channels 2 --test wav --nloops 3 &</action>
      </button>
      <text use-markup="true" width-chars="28">
        <label>$(echo $"Test Sound")</label>
      </text>
    </hbox>
    <hbox>
      <button>
        <input file>$ICONS/audio-volume-high-panel.png</input>
        <action>desktop-defaults-run -t alsamixer &</action>
      </button>
      <text use-markup="true" width-chars="28">
        <label>$(echo $"Adjust Mixer")</label>
      </text>
    </hbox>
    <hbox>
      <button>
        <input file>$ICONS/audio-equalizer.png</input>
        <action>desktop-defaults-run -t alsamixer -D equal &</action>
      </button>
      <text use-markup="true" width-chars="28">
        <label>$(echo $"Alsamixer Equalizer")</label>
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
