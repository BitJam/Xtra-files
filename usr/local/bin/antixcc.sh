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
# Latest Change: 01 May 2016 by anticapitalista: Use 1 script and use hides if nor present on antiX-base
# Acknowledgements: Original script by KDulcimer of TinyMe. http://tinyme.mypclinuxos.com
#################################################################################################################################################

TEXTDOMAINDIR=/usr/share/locale
TEXTDOMAIN=antixcc.sh
# Options
ICONS=/usr/share/icons/antiX
ICONS2=/usr/share/pixmaps

EDITOR="geany -i"

Desktop=$"Desktop" System=$"System" Network=$"Network" Shares=$"Shares" Session=$"Session"
Live=$"Live" Disks=$"Disks" Hardware=$"Hardware" Drivers=$"Drivers" Maintenance=$"Maintenance"
dpi_label=$(printf "%s (DPI)" $"Set Font Size")

[ -d $HOME/.fluxbox -a -e /usr/share/xsessions/fluxbox.desktop ] \
    && edit_fluxbox=$(cat <<Edit_Fluxbox
    <hbox>
      <button>
        <input file>$ICONS/gnome-documents.png</input>
        <action>$EDITOR $HOME/.fluxbox/overlay $HOME/.fluxbox/keys $HOME/.fluxbox/init $HOME/.fluxbox/startup $HOME/.fluxbox/apps $HOME/.fluxbox/menu &</action>
      </button>
      <text use-markup="true" width-chars="32">
        <label>$(echo $"Edit Fluxbox Settings")</label>
      </text>
    </hbox>
Edit_Fluxbox
)

[ -d $HOME/.icewm -a -e /usr/share/xsessions/icewm-session.desktop ] \
    && edit_icewm=$(cat <<Edit_Icewm
    <hbox>
      <button>
        <input file>$ICONS/gnome-documents.png</input>
        <action>$EDITOR $HOME/.icewm/winoptions $HOME/.icewm/preferences $HOME/.icewm/keys $HOME/.icewm/startup $HOME/.icewm/toolbar $HOME/.icewm/menu &</action>
      </button>
      <text use-markup="true" width-chars="32">
        <label>$(echo $"Edit IceWM Settings")</label>
      </text>
    </hbox>
Edit_Icewm
)

[ -d $HOME/.jwm -a -e /usr/share/xsessions/jwm.desktop ] \
    && edit_jwm=$(cat <<Edit_Jwm
    <hbox>
      <button>
        <input file>$ICONS/cs-desktop-effects.png</input>
        <action>$EDITOR $HOME/.jwm/preferences $HOME/.jwm/keys $HOME/.jwm/tray $HOME/.jwm/startup $HOME/.jwmrc $HOME/.jwm/menu &</action>
      </button>
      <text use-markup="true" width-chars="32">
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
        <action>gksu "$EDITOR /live/boot-dev/boot/syslinux/syslinux.cfg &</action>
      </button>
      <text use-markup="true" width-chars="32">
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
      <text use-markup="true" width-chars="32">
        <label>$(echo $"Edit Exclude files")</label>
      </text>
    </hbox>
Edit_Excludes
)

global_dir=/etc/desktop-session
test -d $global_dir  && edit_global=$(cat <<Edit_Global
    <hbox>
      <button>
        <input file>$ICONS/gnome-session.png</input>
        <action>gksu $EDITOR $global_dir/*.conf $global_dir/startup &</action>
      </button>
      <text use-markup="true" width-chars="32">
        <label>$(echo $"Global Desktop-Session")</label>
      </text>
    </hbox>
Edit_Global
)

if test -x /usr/sbin/synaptic; then 
    edit_synaptic=$(cat <<Edit_Synaptic
    <hbox>
      <button>
        <input file>$ICONS2/synaptic.png</input>
        <action>gksu synaptic &</action>
      </button>
      <text use-markup="true" width-chars="32">
        <label>$(echo $"Manage Packages")</label>
      </text>
    </hbox>
Edit_Synaptic
)

elif test -x /usr/local/bin/cli-aptiX; then
    edit_synaptic=$(cat <<Edit_Synaptic
    <hbox>
      <button>
        <input file>$ICONS2/synaptic.png</input>
        <action>desktop-defaults-run -t sudo /usr/local/bin/cli-aptiX --pause &</action>
      </button>
      <text use-markup="true" width-chars="32">
        <label>$(echo $"Manage Packages")</label>
      </text>
    </hbox>
Edit_Synaptic
)
fi

bootrepair_prog=/usr/sbin/bootrepair
test -x $bootrepair_prog  && edit_bootrepair=$(cat <<Edit_Bootrepair
    <hbox>
      <button>
        <input file>$ICONS/computer.png</input>
        <action>gksu bootrepair &</action>
      </button>
      <text use-markup="true" width-chars="32">
        <label>$(echo $"Boot Repair")</label>
      </text>
    </hbox>
Edit_Bootrepair
)

wicd_prog=/usr/bin/wicd-gtk
test -x $wicd_prog  && edit_wicd=$(cat <<Edit_Wicd
    <hbox>
      <button>
        <input file>$ICONS/nm-device-wireless.png</input>
        <action>wicd-gtk &</action>
      </button>
      <text use-markup="true" width-chars="32">
        <label>$(echo $"Connect Wirelessly (wicd)")</label>
      </text>
    </hbox>
Edit_Wicd
)

firewall_prog=/usr/bin/gufw
test -x $firewall_prog  && edit_firewall=$(cat <<Edit_Firewall
    <hbox>
      <button>
        <input file>$ICONS/firewall.png</input>
        <action>gksu gufw &</action>
      </button>
      <text use-markup="true" width-chars="32">
        <label>$(echo $"Manage Firewall")</label>
      </text>
    </hbox>
Edit_Firewall
)

backup_prog=/usr/bin/luckybackup
test -x $backup_prog  && edit_backup=$(cat <<Edit_Backup
    <hbox>
      <button>
        <input file>$ICONS/luckybackup.png</input>
        <action>gksu luckybackup &</action>
      </button>
      <text use-markup="true" width-chars="32">
        <label>$(echo $"Backup Your System")</label>
      </text>
    </hbox>
Edit_Backup
)

equalizer_prog=/usr/bin/alsamixer
test -x $equalizer_prog  && edit_equalizer=$(cat <<Edit_Equalizer
    <hbox>
      <button>
        <input file>$ICONS2/alsamixer-equalizer.png</input>
        <action>desktop-defaults-run -t alsamixer -D equal &</action>
      </button>
      <text use-markup="true" width-chars="32">
        <label>$(echo $"Alsamixer Equalizer")</label>
      </text>
    </hbox>
Edit_Equalizer
)

unetbootin_prog=/usr/bin/unetbootin
test -x $unetbootin_prog  && edit_unetbootin=$(cat <<Edit_Unetbootin
    <hbox>
      <button>
        <input file>$ICONS/usb-creator.png</input>
        <action>gksu unetbootin &</action>
      </button>
      <text use-markup="true" width-chars="32">
        <label>$(echo $"Install to USB retain partitions (UNetbootin)")</label>
      </text>
    </hbox>
Edit_Unetbootin
)

printer_prog=/usr/bin/system-config-printer
test -x $printer_prog  && edit_printer=$(cat <<Edit_Printer
    <hbox>
      <button>
        <input file>$ICONS2/hplj1020_icon.png</input>
        <action>system-config-printer &</action>
      </button>
      <text use-markup="true" width-chars="32">
        <label>$(echo $"Setup a Printer")</label>
      </text>
    </hbox>
Edit_Printer
)

livekernel_prog=/usr/local/bin/live-kernel-updater
test -x $livekernel_prog && edit_livekernel=$(cat <<Edit_Livekernel
    <hbox>
      <button>
        <input file>$ICONS/usb-creator.png</input>
        <action>desktop-defaults-run -t sudo /usr/local/bin/live-kernel-updater --pause &</action>
      </button>
      <text use-markup="true" width-chars="32">
        <label>$(echo $"Live-usb kernel updater")</label>
      </text>
    </hbox>
Edit_Livekernel
)

lxkeymap_prog=/usr/bin/lxkeymap
test -x $lxkeymap_prog && edit_lxkeymap=$(cat <<Edit_Lxkeymap
    <hbox>
      <button>
        <input file>$ICONS/keyboard.png</input>
        <action>lxkeymap &</action>
      </button>
      <text use-markup="true" width-chars="32">
        <label>$(echo $"Change Keyboard Layout for Session")</label>
      </text>
    </hbox>
Edit_Lxkeymap
)

fskbsetting_prog=/usr/bin/fskbsetting
test -d $fskbsetting_prog && edit_fskbsetting=$(cat <<Edit_Fskbsetting
    <hbox>
      <button>
        <input file>$ICONS/usb-creator.png</input>
        <action>gksu fskbsetting &</action>
      </button>
      <text use-markup="true" width-chars="32">
        <label>$(echo $"Set System Keymap")</label>
      </text>
    </hbox>
Edit_Fskbsetting
)

wallpaper_prog=/usr/local/bin/wallpaper.py
test -x $wallpaper_prog && edit_wallpaper=$(cat <<Edit_Wallpaper
    <hbox>
      <button>
        <input file>$ICONS/preferences-desktop-wallpaper.png</input>
        <action>wallpaper.py &</action>
      </button>
      <text use-markup="true" width-chars="32">
        <label>$(echo $"Choose Wallpaper")</label>
      </text>
    </hbox>
Edit_Wallpaper
)

conky_prog=/usr/bin/conky
test -x $conky_prog && test -w $HOME/.conkyrc && edit_conky=$(cat <<Edit_Conky
    <hbox>
      <button>
        <input file>$ICONS/utilities-system-monitor.png</input>
        <action>desktop-defaults-run -te $HOME/.conkyrc &</action>
      </button>
      <text use-markup="true" width-chars="32">
        <label>$(echo $"Edit System Monitor(conky)")</label>
      </text>
    </hbox>
Edit_Conky
)

lxappearance_prog=/usr/bin/lxappearance
test -x $lxappearance_prog && edit_lxappearance=$(cat <<Edit_Lxappearance
    <hbox>
      <button>
        <input file>$ICONS/preferences-desktop-theme.png</input>
        <action>lxappearance &</action>
      </button>
      <text use-markup="true" width-chars="32">
        <label>$(echo $"Change Gtk2 and Icon Themes")</label>
      </text>
    </hbox>
Edit_Lxappearance
)

prefapps_prog=/usr/local/bin/desktop-defaults-set
test -x $prefapps_prog && edit_prefapps=$(cat <<Edit_Prefapps
    <hbox>
      <button>
        <input file>$ICONS/applications-system.png</input>
        <action>desktop-defaults-set &</action>
      </button>
      <text use-markup="true" width-chars="32">
        <label>$(echo $"Preferred Applications")</label>
      </text>
    </hbox>
Edit_Prefapps
)

packageinstaller_prog=/usr/bin/packageinstaller
test -x $packageinstaller_prog && edit_packageinstaller=$(cat <<Edit_Packageinstaller
    <hbox>
      <button>
        <input file>$ICONS/packageinstaller.png</input>
        <action>gksu packageinstaller &</action>
      </button>
      <text use-markup="true" width-chars="32">
        <label>$(echo $"Package Installer")</label>
      </text>
    </hbox>
Edit_Packageinstaller
)

svconf_prog=/usr/sbin/sysv-rc-conf
test -x $sysvconf_prog && edit_sysvconf=$(cat <<Edit_Sysvconf
    <hbox>
      <button>
        <input file>$ICONS/gnome-settings-default-applications.png</input>
        <action>desktop-defaults-run -t sudo sysv-rc-conf &</action>
      </button>
      <text use-markup="true" width-chars="32">
        <label>$(echo $"Choose Startup Services")</label>
      </text>
    </hbox>
Edit_Sysvconf
)

tzdata_dir=/usr/share/zoneinfo
tzdata_prog=/usr/sbin/dpkg-reconfigure
test -x $tzdata_prog && && test -d $tzdata_dir && edit_tzdata=$(cat <<Edit_Tzdata
    <hbox>
      <button>
        <input file>$ICONS/time-admin.png</input>
        <action>desktop-defaults-run -t sudo dpkg-reconfigure tzdata &</action>
      </button>
      <text use-markup="true" width-chars="32">
        <label>$(echo $"Set Date and Time")</label>
      </text>
    </hbox>
Edit_Tzdata
)

ceni_prog=/usr/bin/ceni
test -x $ceni_prog && edit_ceni=$(cat <<Edit_Ceni
    <hbox>
      <button>
        <input file>$ICONS/network-wired.png</input>
        <action>desktop-defaults-run -t sudo ceni &</action>
      </button>
      <text use-markup="true" width-chars="32">
        <label>$(echo $"Network Interfaces (ceni)")</label>
      </text>
    </hbox>
Edit_Ceni
)

umts_prog=/usr/bin/umts-panel
test -x $umts_prog && edit_umts=$(cat <<Edit_Umts
    <hbox>
      <button>
        <input file>$ICONS/network-wired.png</input>
        <action>umts-panel &</action>
      </button>
      <text use-markup="true" width-chars="32">
        <label>$(echo $"Configure GPRS/UMTS")</label>
      </text>
    </hbox>
Edit_Umts
)

connectshares_prog=/usr/local/bin/connectshares-config
test -x $connectshares_prog && edit_connectshares=$(cat <<Edit_Connectshares
    <hbox>
      <button>
        <input file>$ICONS/connectshares-config.png</input>
        <action>connectshares-config &</action>
      </button>
      <text use-markup="true" width-chars="32">
        <label>$(echo $"Configure Connectshares")</label>
      </text>
    </hbox>
Edit_Connectshares
)

disconnectshares_prog=/usr/local/bin/disconnectshares
test -x $disconnectshares_prog && edit_disconnectshares=$(cat <<Edit_Disconnectshares
    <hbox>
      <button>
        <input file>$ICONS/connectshares.png</input>
        <action>disconnectshares &</action>
      </button>
      <text use-markup="true" width-chars="32">
        <label>$(echo $" Disconnectshares")</label>
      </text>
    </hbox>
Edit_Disconnectshares
)

droopy_prog=/usr/local/bin/droopy.sh
test -x $droopy_prog && edit_droopy=$(cat <<Edit_Droopy
    <hbox>
      <button>
        <input file>$ICONS2/droopy.png</input>
        <action>droopy.sh &</action>
      </button>
      <text use-markup="true" width-chars="32">
        <label>$(echo $"Share Files via Droopy")</label>
      </text>
    </hbox>
Edit_Droopy
)

gnomeppp_prog=/usr/bin/gnome-ppp
test -x $gnomeppp_prog && edit_gnomeppp=$(cat <<Edit_Gnomeppp
    <hbox>
      <button>
        <input file>$ICONS/internet-telephony.png</input>
        <action>gnome-ppp &</action>
      </button>
      <text use-markup="true" width-chars="32">
        <label>$(echo $"Configure Dial-Up")</label>
      </text>
    </hbox>
Edit_Gnomeppp
)

wpasupplicant_prog=/usr/sbin/doc/wpa_gui
test -x $wpasupplicant_prog && edit_wpasupplicant=$(cat <<Edit_Wpasupplicant
    <hbox>
      <button>
        <input file>$ICONS/nm-device-wireless.png</input>
        <action>/usr/sbin/wpa_gui &</action>
      </button>
      <text use-markup="true" width-chars="32">
        <label>$(echo $"Configure wpa_supplicant")</label>
      </text>
    </hbox>
Edit_Wpasupplicant
)

pppoeconf_prog=/usr/sbin/pppoeconf
test -x $pppoeconf_prog && edit_pppoeconf=$(cat <<Edit_Pppoeconf
    <hbox>
      <button>
        <input file>$ICONS/internet-telephony.png</input>
        <action>desktop-defaults-run -t /usr/sbin/pppoeconf &</action>
      </button>
      <text use-markup="true" width-chars="32">
        <label>$(echo $"ADSL/PPPOE configuration")</label>
      </text>
    </hbox>
Edit_Pppoeconf
)

adblock_dir=/usr/local/bin/block-advert.sh
test -x $adblock_prog && edit_adblock=$(cat <<Edit_Adblock
    <hbox>
      <button>
        <input file>$ICONS2/advert-block.png</input>
        <action>gksu block-advert.sh &</action>
      </button>
      <text use-markup="true" width-chars="32">
        <label>$(echo $"Adblock")</label>
      </text>
    </hbox>
Edit_Adblock
)

slim_cc=/usr/local/bin/antixccslim.sh
slim_prog=/usr/bin/slim
test -x $slim_prog && test -x $slim_cc && edit_slim=$(cat <<Edit_Slim
    <hbox>
      <button>
        <input file>$ICONS/preferences-desktop-wallpaper.png</input>
        <action>gksu antixccslim.sh &</action>
      </button>
      <text use-markup="true" width-chars="32">
        <label>$(echo $"Change Slim Background")</label>
      </text>
    </hbox>
Edit_Slim
)

grub_prog=/usr/local/bin/antixccgrub.sh
test -x $grub_prog && edit_grub=$(cat <<Edit_Grub
    <hbox>
      <button>
        <input file>$ICONS/screensaver.png</input>
        <action>gksu antixccgrub.sh &</action>
      </button>
      <text use-markup="true" width-chars="32">
        <label>$(echo $"Grub Boot Image (jpg only)")</label>
      </text>
    </hbox>
Edit_Grub
)

which $EDITOR &>/dev/null && edit_confroot=$(cat <<Edit_Confroot
    <hbox>
      <button>
        <input file>$ICONS/gnome-documents.png</input>
        <action>gksu $EDITOR /etc/fstab /etc/default/keyboard /etc/grub.d/* /etc/slim.conf /etc/apt/sources.list.d/*.list &</action>
      </button>
      <text use-markup="true" width-chars="32">
        <label>$(echo $"Edit Config Files")</label>
      </text>
    </hbox>
Edit_Confroot
)

arandr_prog=/usr/bin/arandr
test -x $arandr_prog && edit_arandr=$(cat <<Edit_Arandr
    <hbox>
      <button>
        <input file>$ICONS/video-display.png</input>
        <action>gksu arandr &</action>
      </button>
      <text use-markup="true" width-chars="32">
        <label>$(echo $"Set Screen Resolution")</label>
      </text>
    </hbox>
Edit_Arandr
)

gksu_prog=/usr/bin/gksu-properties
test -x $gksu_prog && edit_gksu=$(cat <<Edit_Gksu
    <hbox>
      <button>
        <input file>$ICONS2/gksu.png</input>
        <action>gksu-properties &</action>
      </button>
      <text use-markup="true" width-chars="32">
        <label>$(echo $"Password Prompt(su/sudo)")</label>
      </text>
    </hbox>
Edit_Gksu
)

slimlogin_prog=/usr/local/bin/slim-login
test -x $slimlogin_prog && edit_slimlogin=$(cat <<Edit_Slimlogin
    <hbox>
      <button>
        <input file>$ICONS/preferences-system-login.png</input>
        <action>gksu slim-login &</action>
      </button>
      <text use-markup="true" width-chars="32">
        <label>$(echo $"Set auto-login")</label>
      </text>
    </hbox>
Edit_Slimlogin
)

screenblank_prog=/usr/local/bin/set-screen-blank
test -x $screenblank_prog && edit_screenblank=$(cat <<Edit_Screenblank
    <hbox>
      <button>
        <input file>$ICONS/screensaver.png</input>
        <action>set-screen-blank &</action>
      </button>
      <text use-markup="true" width-chars="32">
        <label>$(echo $"Set Screen Blanking")</label>
      </text>
    </hbox>
Edit_Screenblank
)

desktopsession_dir=/usr/share/doc/desktop-session-antix
test -d $desktopsession_dir  && edit_desktopsession=$(cat <<Edit_Desktopsession
    <hbox>
      <button>
        <input file>$ICONS/preferences-system-session.png</input>
        <action>$EDITOR $HOME/.desktop-session/*.conf $HOME/.desktop-session/startup &</action>
      </button>
      <text use-markup="true" width-chars="32">
        <label>$(echo $"User Desktop-Session")</label>
      </text>
    </hbox>
Edit_Desktopsession
)

automount_prog=/usr/local/bin/automount-config
test -x $automount_prog && edit_automount=$(cat <<Edit_Automount
    <hbox>
      <button>
        <input file>$ICONS/mountbox.png</input>
        <action>automount-config &</action>
      </button>
      <text use-markup="true" width-chars="32">
        <label>$(echo $"Configure Automounting")</label>
      </text>
    </hbox>
Edit_Automount
)

mountbox_prog=/usr/local/bin/mountbox
test -x $mountbox_prog && edit_mountbox=$(cat <<Edit_Mountbox
    <hbox>
      <button>
        <input file>$ICONS/mountbox.png</input>
        <action>mountbox &</action>
      </button>
      <text use-markup="true" width-chars="32">
        <label>$(echo $"Mount Connected Devices")</label>
      </text>
    </hbox>
Edit_Mountbox
)

liveusb_prog_g=/usr/local/bin/live-usb-maker-gui
liveusb_prog=/usr/local/bin/live-usb-maker
if test -x $liveusb_prog_g; then 
    edit_liveusb=$(cat <<Edit_Liveusb
    <hbox>
      <button>
        <input file>$ICONS/usb-creator.png</input>
        <action>gksu live-usb-maker-gui &</action>
      </button>
      <text use-markup="true" width-chars="32">
        <label>$(echo $"Install to USB")</label>
      </text>
    </hbox>
Edit_Liveusb
)

elif test -x $liveusb_prog; then
    edit_liveusb=$(cat <<Edit_Liveusb
    <hbox>
      <button>
        <input file>$ICONS/usb-creator.png</input>
        <action> desktop-defaults-run sudo &live-usb-maker &</action>
      </button>
      <text use-markup="true" width-chars="32">
        <label>$(echo $"Install to USB")</label>
      </text>
    </hbox>
Edit_Liveusb
)
fi

partimage_prog=/usr/sbin/partimage
test -x $partimage_prog && edit_partimage=$(cat <<Edit_Partimage
    <hbox>
      <button>
        <input file>$ICONS/drive-harddisk-system.png</input>
        <action>desktop-defaults-run -t sudo partimage &</action>
      </button>
      <text use-markup="true" width-chars="32">
        <label>$(echo $"Image a Partition")</label>
      </text>
    </hbox>
Edit_Partimage
)

grsync_prog=/usr/bin/grsync
test -x $grsync_prog && edit_grsync=$(cat <<Edit_Grsync
    <hbox>
      <button>
        <input file>$ICONS/grsync.png</input>
        <action>grsync &</action>
      </button>
      <text use-markup="true" width-chars="32">
        <label>$(echo $"Synchronize Directories")</label>
      </text>
    </hbox>
Edit_Grsync
)

gparted_prog=/usr/sbin/gparted
test -x $gparted_prog && edit_gparted=$(cat <<Edit_Gparted
    <hbox>
      <button>
        <input file>$ICONS/gparted.png</input>
        <action>gksu gparted &</action>
      </button>
      <text use-markup="true" width-chars="32">
        <label>$(echo $"Partition a Drive")</label>
      </text>
    </hbox>
Edit_Gparted
)

setdpi_prog=/usr/local/bin/set-dpi
test -x $setdpi_prog && edit_setdpi=$(cat <<Edit_Setdpi
    <hbox>
      <button>
        <input file>$ICONS/fonts.png</input>
        <action>set-dpi &</action> 
      </button>
      <text use-markup="true" width-chars="32">
        <label>$dpi_label</label>
      </text>
    </hbox>
Edit_Setdpi
)

inxi_prog=/usr/local/bin/inxi-gui
test -x $inxi_prog && edit_inxi=$(cat <<Edit_Inxi
    <hbox>
      <button>
        <input file>$ICONS2/info_blue.png</input>
        <action>inxi-gui &</action> 
      </button>
      <text use-markup="true" width-chars="32">
        <label>$(echo $"PC Information")</label>
      </text>
    </hbox>
Edit_Inxi
)

mouse_prog=/usr/local/bin/ds-mouse
test -x $mouse_prog && edit_mouse=$(cat <<Edit_Mouse
    <hbox>
      <button>
        <input file>$ICONS/input-mouse.png</input>
        <action>ds-mouse &</action> 
      </button>
      <text use-markup="true" width-chars="32">
        <label>$(echo $"Configure Mouse")</label>
      </text>
    </hbox>
Edit_Mouse
)

soundcard_prog=/usr/local/bin/alsa-set-default-card
test -x $soundcard_prog && edit_soundcard=$(cat <<Edit_Soundcard
    <hbox>
      <button>
        <input file>$ICONS2/soundcard.png</input>
        <action>alsa-set-default-card &</action> 
      </button>
      <text use-markup="true" width-chars="32">
        <label>$(echo $"Set Default Sound Card")</label>
      </text>
    </hbox>
Edit_Soundcard
)

mixer_prog=/usr/bin/alsamixer
test -x $mixer_prog && edit_mixer=$(cat <<Edit_Mixer
    <hbox>
      <button>
        <input file>$ICONS/audio-volume-high-panel.png</input>
        <action>desktop-defaults-run -t alsamixer &</action> 
      </button>
      <text use-markup="true" width-chars="32">
        <label>$(echo $"Adjust Mixer")</label>
      </text>
    </hbox>
Edit_Mixer
)

ddm_prog=/usr/local/bin/ddm-mx
test -x $ddm_prog && edit_atidriver=$(cat <<Edit_Atidriver
    <hbox>
      <button>
        <input file>$ICONS2/amd-ddm-mx.png</input>
        <action>desktop-defaults-run -t su-to-root -c "/usr/local/bin/ddm-mx -i ati" &</action> 
      </button>
      <text use-markup="true" width-chars="32">
        <label>$(echo $"AMD/ATI fglrx Driver Installer")</label>
      </text>
    </hbox>
Edit_Atidriver
)

test -x $ddm_prog && edit_nvdriver=$(cat <<Edit_Nvdriver
    <hbox>
      <button>
        <input file>$ICONS2/nvidia-ddm-mx.png</input>
        <action>desktop-defaults-run -t su-to-root -c "/usr/local/bin/ddm-mx -i nvidia" &</action> 
      </button>
      <text use-markup="true" width-chars="32">
        <label>$(echo $"Nvidia Driver Installer")</label>
      </text>
    </hbox>
Edit_Nvdriver
)

ndiswrapper_prog=/usr/sbin/ndisgtk
test -x $ndiswrapper_prog && edit_ndiswrapper=$(cat <<Edit_Ndiswrapper
    <hbox>
      <button>
        <input file>$ICONS/computer.png</input>
        <action>gksu /usr/sbin/ndisgtk &</action> 
      </button>
      <text use-markup="true" width-chars="32">
        <label>$(echo $"MS Windows Wireless Drivers")</label>
      </text>
    </hbox>
Edit_Ndiswrapper
)

snapshot_prog=/usr/bin/isosnapshot
test -x $snapshot_prog && edit_snapshot=$(cat <<Edit_Snapshot
    <hbox>
      <button>
        <input file>$ICONS/preferences-system.png</input>
        <action>gksu isosnapshot &</action> 
      </button>
      <text use-markup="true" width-chars="32">
        <label>$(echo $"Create Snapshot(ISO)")</label>
      </text>
    </hbox>
Edit_Snapshot
)

soundtest_prog=/usr/bin/speaker-test
test -x $soundtest_prog  && edit_soundtest=$(cat <<Edit_Soundtest
    <hbox>
      <button>
        <input file>$ICONS/preferences-desktop-sound.png</input>
        <action>urxvt -e speaker-test --channels 2 --test wav --nloops 3 &</action> 
      </button>
      <text use-markup="true" width-chars="32">
        <label>$(echo $"Test Sound")</label>
      </text>
    </hbox>
Edit_Soundtest
)

menumanager_prog=/usr/local/bin/menu_manager.sh
test -x $menumanager_prog && edit_menumanager=$(cat <<Edit_Menumanager
    <hbox>
      <button>
        <input file>$ICONS2/menu_manager.png</input>
        <action>sudo menu_manager.sh &</action> 
      </button>
      <text use-markup="true" width-chars="32">
        <label>$(echo $"Edit menus")</label>
      </text>
    </hbox>
Edit_Menumanager
)

usermanager_prog=/usr/local/bin/user-management
test -x $usermanager_prog && edit_usermanager=$(cat <<Edit_Usermanager
    <hbox>
      <button>
        <input file>$ICONS/config-users.png</input>
        <action>gksu user-management &</action> 
      </button>
      <text use-markup="true" width-chars="32">
        <label>$(echo $"User Manager")</label>
      </text>
    </hbox>
Edit_Usermanager
)

galternatives_prog=/usr/bin/galternatives
test -x $galternatives_prog && edit_galternatives=$(cat <<Edit_Galternatives
    <hbox>
      <button>
        <input file>$ICONS2/galternatives.png</input>
        <action>galternatives &</action> 
      </button>
      <text use-markup="true" width-chars="32">
        <label>$(echo $"Alternatives Configurator")</label>
      </text>
    </hbox>
Edit_Galternatives
)

codecs_prog=/usr/sbin/codecs
test -x $codecs_prog && edit_codecs=$(cat <<Edit_Codecs
    <hbox>
      <button>
        <input file>$ICONS/applications-system.png</input>
        <action>su-to-root -X -c codecs &</action> 
      </button>
      <text use-markup="true" width-chars="32">
        <label>$(echo $"Install Restricted Codecs")</label>
      </text>
    </hbox>
Edit_Codecs
)

broadcom_prog=/usr/sbin/broadcom-manager
test -x $broadcom_prog && edit_broadcom=$(cat <<Edit_Broadcom
    <hbox>
      <button>
        <input file>$ICONS/palimpsest.png</input>
        <action>su-to-root -X -c broadcom-manager &</action> 
      </button>
      <text use-markup="true" width-chars="32">
        <label>$(echo $"Network Troubleshooting")</label>
      </text>
    </hbox>
Edit_Broadcom
)

[ -e /etc/live/config/save-persist -o -e /etc/live/config/persist-save.conf ]  && persist_save=$(cat <<Persist_Save
    <hbox>
      <button>
        <input file>$ICONS/palimpsest.png</input>
        <action>gksu persist-save &</action>
      </button>
      <text use-markup="true" width-chars="32">
        <label>$(echo $"Save root persistence")</label>
      </text>
    </hbox>
Persist_Save
)

[ -e /etc/live/config/remasterable -o -e /etc/live/config/remaster-live.conf ] && live_remaster=$(cat <<Live_Remaster
    <hbox>
      <button>
        <input file>$ICONS/preferences-desktop.png</input>
        <action>gksu live-remaster &</action>
      </button>
      <text use-markup="true" width-chars="32">
        <label>$(echo $"Remaster-Customize Live")</label>
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
      <text use-markup="true" width-chars="32">
        <label>$(echo $"Configure live persistence")</label>
      </text>
    </hbox>
$edit_livekernel
$edit_bootloader
$persist_save
  </vbox>
  <vbox>
    <hbox>
      <button>
        <input file>$ICONS/palimpsest.png</input>
        <action>gksu persist-makefs &</action>
      </button>
      <text use-markup="true" width-chars="32">
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
if grep -q " /live/aufs " /proc/mounts; then
    tab_labels="$Desktop|$System|$Network|$Shares|$Session|$Live|$Disks|$Hardware|$Drivers|$Maintenance"

else
    tab_labels="$Desktop|$System|$Network|$Shares|$Session|$Disks|$Hardware|$Drivers|$Maintenance"
    live_tab=
fi

export ControlCenter=$(cat <<End_of_Text
<window title="antiX Control Center" icon="gnome-control-center" window-position="1">
  <vbox>
<notebook tab-pos="0" labels="$tab_labels">
<vbox> <frame> <hbox>
  <vbox>
$edit_wallpaper
$edit_icewm
$edit_jwm
$edit_conky 
  </vbox>
  <vbox>
$edit_setdpi  
$edit_lxappearance
$edit_fluxbox
$edit_prefapps  
  </vbox>
</hbox> </frame> </vbox>
<vbox> <frame> <hbox>
  <vbox>
$edit_synaptic
$edit_packageinstaller   
$edit_sysvconf
$edit_galternatives
  </vbox>
  <vbox>
$edit_confroot
$edit_fskbsetting
$edit_tzdata  
  </vbox>
</hbox> </frame> </vbox>
<vbox> <frame> <hbox>
  <vbox>  
$edit_ceni
$edit_umts
$edit_wicd
$edit_pppoeconf
  </vbox>
  <vbox>
$edit_gnomeppp
$edit_wpasupplicant
$edit_firewall
$edit_adblock
  </vbox>
</hbox> </frame></vbox>
<vbox> <frame> <hbox>
  <vbox>  
$edit_connectshares 
$edit_droopy 
  </vbox>
  <vbox>
$edit_disconnectshares 
$edit_samba
  </vbox>
</hbox> </frame></vbox>
<vbox> <frame> <hbox>
  <vbox>
$edit_lxkeymap 
$edit_slim  
$edit_arandr
$edit_grub
  </vbox>
  <vbox>
$edit_gksu
$edit_slimlogin   
$edit_screenblank    
$edit_desktopsession
  </vbox>
</hbox> </frame> </vbox>
$live_tab
<vbox> <frame> <hbox>
  <vbox>
$edit_automount
$edit_mountbox   
$edit_unetbootin
  </vbox>
  <vbox>
$edit_liveusb
$edit_partimage
$edit_grsync
$edit_gparted
  </vbox>
</hbox> </frame> </vbox>
<vbox> <frame> <hbox>
  <vbox>
$edit_printer 
$edit_inxi 
$edit_mouse
  </vbox>
  <vbox>
$edit_soundcard
$edit_soundtest
$edit_mixer
$edit_equalizer
  </vbox>
</hbox> </frame> </vbox>
<vbox> <frame> <hbox>
  <vbox>
$edit_nvdriver
$edit_codecs
  </vbox>
  <vbox>
$edit_ndiswrapper
  </vbox>
</hbox> </frame> </vbox>
<vbox> <frame> <hbox>
  <vbox>
$edit_snapshot
$edit_backup
$edit_broadcom
  </vbox>
  <vbox>
$edit_bootrepair
$edit_menumanager
$edit_usermanager
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
