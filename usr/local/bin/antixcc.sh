#!/bin/bash
# File Name: controlcenter.sh
# Purpose: all-in-one control centre for antiX
# Authors: OU812 and minor modifications by anticapitalista
# Latest Change:
# 20 August 2008
# 11 January 2009 and renamed antixcc.sh
# 15 August 2009 some apps and labels altered.
# 09 March 2012 by anticapitalista. Added Live section.
# 22 March 2012 by anticapitalista. Added jwm config options and edited admin options.
# 18 April 2012 by anticapitalista. mountbox-antix opens as user not root.
# 06 October 2012 by anticapitalista. Function for ICONS. New icon theme.
# 26 October 2012 by anticapitalista. Includes gksudo and ktsuss.
# 12 May 2013 by anticapitalista. Let user set default apps.
# 05 March 2015 by BitJam: Add alsa-set-card, edit excludes, edit bootloader.  Fix indentation.
#   * Hide live tab on non-live systems.  Use echo instead of gettext.
#   * Remove unneeded doublequotes between tags.  Use $(...) instead of `...`.
# 01 May 2016 by anticapitalista: Use 1 script and use hides if nor present on antiX-base
# 11 July 2017 by BitJam:
#   * use a subroutine to greatly consolidate code
#   * use existence of executable as the key instead of documentation directory
#     perhaps I should switch to "which" or "type"
#   * move set-dpi to desktop tab
#   * enable ati driver button in hardware tab
#
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

entry() {
    local image=$1  action=$2  text=$3
    cat<<Entry
    <hbox>
      <button>
        <input file>$image</input>
        <action>$action</action>
      </button>
      <text use-markup="true" width-chars="32">
        <label>$text</label>
      </text>
    </hbox>
Entry
}

[ -d $HOME/.fluxbox -a -e /usr/share/xsessions/fluxbox.desktop ] && fluxbox_entry=$(entry \
    "$ICONS/gnome-documents.png" \
    "$EDITOR $HOME/.fluxbox/overlay $HOME/.fluxbox/keys $HOME/.fluxbox/init $HOME/.fluxbox/startup $HOME/.fluxbox/apps $HOME/.fluxbox/menu &" \
    $"Edit Fluxbox Settings")

[ -d $HOME/.icewm -a -e /usr/share/xsessions/icewm-session.desktop ] && icewm_entry=$(entry \
    $ICONS/gnome-documents.png \
    "$EDITOR $HOME/.icewm/winoptions $HOME/.icewm/preferences $HOME/.icewm/keys $HOME/.icewm/startup $HOME/.icewm/toolbar $HOME/.icewm/menu &" \
    $"Edit IceWM Settings")

[ -d $HOME/.jwm -a -e /usr/share/xsessions/jwm.desktop ] && jwm_entry=$(entry \
    $ICONS/cs-desktop-effects.png \
    "$EDITOR $HOME/.jwm/preferences $HOME/.jwm/keys $HOME/.jwm/tray $HOME/.jwm/startup $HOME/.jwmrc $HOME/.jwm/menu &" \
    $"Edit jwm Settings")

# Edit syslinux.cfg if the device it is own is mounted read-write
grep -q " /live/boot-dev .*\<rw\>" /proc/mounts && bootloader_entry=$(entry \
    $ICONS/preferences-desktop.png \
    "gksu $EDITOR /live/boot-dev/boot/syslinux/syslinux.cfg &" \
    $"Edit Bootloader menu")

test -d /usr/local/share/excludes && excludes_entry=$(entry \
    $ICONS/remastersys.png \
    "gksu $EDITOR $excludes_dir/*.list &" \
    $"Edit Exclude files")

test -d /etc/desktop-session && global_entry=$(entry \
    $ICONS/gnome-session.png \
    "gksu $EDITOR $global_dir/*.conf $global_dir/startup &" \
    $"Global Desktop-Session")

if test -x /usr/sbin/synaptic; then synaptic_entry=$(entry \
    $ICONS2/synaptic.png \
    "gksu synaptic &" \
    $"Manage Packages")

elif test -x /usr/local/bin/cli-aptiX; then synaptic_entry=$(entry \
    $ICONS2/synaptic.png \
    "desktop-defaults-run -t sudo /usr/local/bin/cli-aptiX --pause &" \
    $"Manage Packages")
fi

test -x  /usr/sbin/bootrepair && bootrepair_entry=$(entry \
    $ICONS/computer.png \
    "gksu bootrepair &" \
    $"Boot Repair")

test -x /usr/bin/wicd-gtk && wicd_entry=$(entry \
    $ICONS/nm-device-wireless.png \
    "wicd-gtk &" \
    $"Connect Wirelessly (wicd)")

firewall_prog=/usr/bin/gufw
test -x $firewall_prog  && firewall_entry=$(entry \
    $ICONS/firewall.png \
    "gksu gufw &" \
    $"Manage Firewall")

backup_prog=/usr/bin/luckybackup
test -x $backup_prog  && backup_entry=$(entry \
    $ICONS/luckybackup.png \
    "gksu luckybackup &" \
    $"Backup Your System")

equalizer_prog=/usr/bin/alsamixer
test -x $equalizer_prog  && equalizer_entry=$(entry \
    $ICONS2/alsamixer-equalizer.png \
    "desktop-defaults-run -t alsamixer -D equal &" \
    $"Alsamixer Equalizer")

unetbootin_prog=/usr/bin/unetbootin
test -x $unetbootin_prog  && unetbootin_entry=$(entry \
    $ICONS/usb-creator.png \
    "gksu unetbootin &" \
    $"Install to USB retain partitions (UNetbootin)")

printer_prog=/usr/bin/system-config-printer
test -x $printer_prog  && printer_entry=$(entry \
    $ICONS2/hplj1020_icon.png \
    "system-config-printer &" \
    $"Setup a Printer")

livekernel_prog=/usr/local/bin/live-kernel-updater
test -x $livekernel_prog && livekernel_entry=$(entry \
    $ICONS/usb-creator.png \
    "desktop-defaults-run -t sudo /usr/local/bin/live-kernel-updater --pause &" \
    $"Live-usb kernel updater")

lxkeymap_prog=/usr/bin/lxkeymap
test -x $lxkeymap_prog && lxkeymap_entry=$(entry \
    $ICONS/keyboard.png \
    "lxkeymap &" \
    $"Change Keyboard Layout for Session")

fskbsetting_prog=/usr/bin/fskbsetting
test -x $fskbsetting_prog && fskbsetting_entry=$(entry \
    $ICONS/usb-creator.png \
    "gksu fskbsetting &" \
    $"Set System Keymap")

wallpaper_prog=/usr/local/bin/wallpaper.py
test -x $wallpaper_prog && wallpaper_entry=$(entry \
    $ICONS/preferences-desktop-wallpaper.png \
    "wallpaper.py &" \
    $"Choose Wallpaper")

conky_prog=/usr/bin/conky
test -x $conky_prog && test -w $HOME/.conkyrc && conky_entry=$(entry \
    $ICONS/utilities-system-monitor.png \
    "desktop-defaults-run -te $HOME/.conkyrc &" \
    $"Edit System Monitor(conky)")

lxappearance_prog=/usr/bin/lxappearance
test -x $lxappearance_prog && lxappearance_entry=$(entry \
    $ICONS/preferences-desktop-theme.png \
    "lxappearance &" \
    $"Change Gtk2 and Icon Themes")

prefapps_prog=/usr/local/bin/desktop-defaults-set
test -x $prefapps_prog && prefapps_entry=$(entry \
    $ICONS/applications-system.png \
    "desktop-defaults-set &" \
    $"Preferred Applications")

packageinstaller_prog=/usr/bin/packageinstaller
test -x $packageinstaller_prog && packageinstaller_entry=$(entry \
    $ICONS/packageinstaller.png \
    "gksu packageinstaller &" \
    $"Package Installer")

svconf_prog=/usr/sbin/sysv-rc-conf
test -x $sysvconf_prog && sysvconf_entry=$(entry \
    $ICONS/gnome-settings-default-applications.png \
    "desktop-defaults-run -t sudo sysv-rc-conf &" \
    $"Choose Startup Services")

tzdata_dir=/usr/share/zoneinfo
tzdata_prog=/usr/sbin/dpkg-reconfigure
test -x $tzdata_prog && test -d $tzdata_dir && tzdata_entry=$(entry \
    $ICONS/time-admin.png \
    "desktop-defaults-run -t sudo dpkg-reconfigure tzdata &" \
    $"Set Date and Time")

ceni_prog=/usr/bin/ceni
test -x $ceni_prog && ceni_entry=$(entry \
    $ICONS/network-wired.png \
    "desktop-defaults-run -t sudo ceni &" \
    $"Network Interfaces (ceni)")

umts_prog=/usr/bin/umts-panel
test -x $umts_prog && umts_entry=$(entry \
    $ICONS/network-wired.png \
    "umts-panel &" \
    $"Configure GPRS/UMTS")

connectshares_prog=/usr/local/bin/connectshares-config
test -x $connectshares_prog && connectshares_entry=$(entry \
    $ICONS/connectshares-config.png \
    "connectshares-config &" \
    $"Configure Connectshares")

disconnectshares_prog=/usr/local/bin/disconnectshares
test -x $disconnectshares_prog && disconnectshares_entry=$(entry \
    $ICONS/connectshares.png \
    "disconnectshares &" \
    $" Disconnectshares")

droopy_prog=/usr/local/bin/droopy.sh
test -x $droopy_prog && droopy_entry=$(entry \
    $ICONS2/droopy.png \
    "droopy.sh &" \
    $"Share Files via Droopy")

gnomeppp_prog=/usr/bin/gnome-ppp
test -x $gnomeppp_prog && gnomeppp_entry=$(entry \
    $ICONS/internet-telephony.png \
    "gnome-ppp &" \
    $"Configure Dial-Up")

wpasupplicant_prog=/usr/sbin/wpa_gui
test -x $wpasupplicant_prog && wpasupplicant_entry=$(entry \
    $ICONS/nm-device-wireless.png \
    "/usr/sbin/wpa_gui &" \
    $"Configure wpa_supplicant")

pppoeconf_prog=/usr/sbin/pppoeconf
test -x $pppoeconf_prog && pppoeconf_entry=$(entry \
    $ICONS/internet-telephony.png \
    "desktop-defaults-run -t /usr/sbin/pppoeconf &" \
    $"ADSL/PPPOE configuration")

adblock_prog=/usr/local/bin/block-advert.sh
test -x $adblock_prog && adblock_entry=$(entry \
    $ICONS2/advert-block.png \
    "gksu block-advert.sh &" \
    $"Adblock")

slim_cc=/usr/local/bin/antixccslim.sh
slim_prog=/usr/bin/slim
test -x $slim_prog && test -x $slim_cc && slim_entry=$(entry \
    $ICONS/preferences-desktop-wallpaper.png \
    "gksu antixccslim.sh &" \
    $"Change Slim Background")

grub_prog=/usr/local/bin/antixccgrub.sh
test -x $grub_prog && grub_entry=$(entry \
    $ICONS/screensaver.png \
    "gksu antixccgrub.sh &" \
    $"Grub Boot Image (jpg only)")

which ${EDITOR%% *} &>/dev/null && confroot_entry=$(entry \
    $ICONS/gnome-documents.png \
    "gksu $EDITOR /etc/fstab /etc/default/keyboard /etc/grub.d/* /etc/slim.conf /etc/apt/sources.list.d/*.list &" \
    $"Edit Config Files")

arandr_prog=/usr/bin/arandr
test -x $arandr_prog && arandr_entry=$(entry \
    $ICONS/video-display.png \
    "gksu arandr &" \
    $"Set Screen Resolution")

gksu_prog=/usr/bin/gksu-properties
test -x $gksu_prog && gksu_entry=$(entry \
    $ICONS2/gksu.png \
    "gksu-properties &" \
    $"Password Prompt(su/sudo)")

slimlogin_prog=/usr/local/bin/slim-login
test -x $slimlogin_prog && slimlogin_entry=$(entry \
    $ICONS/preferences-system-login.png \
    "gksu slim-login &" \
    $"Set auto-login")

screenblank_prog=/usr/local/bin/set-screen-blank
test -x $screenblank_prog && screenblank_entry=$(entry \
    $ICONS/screensaver.png \
    "set-screen-blank &" \
    $"Set Screen Blanking")

desktopsession_dir=/usr/share/doc/desktop-session-antix
test -d $desktopsession_dir  && desktopsession_entry=$(entry \
    $ICONS/preferences-system-session.png \
    "$EDITOR $HOME/.desktop-session/*.conf $HOME/.desktop-session/startup &" \
    $"User Desktop-Session")

automount_prog=/usr/local/bin/automount-config
test -x $automount_prog && automount_entry=$(entry \
    $ICONS/mountbox.png \
    "automount-config &" \
    $"Configure Automounting")

mountbox_prog=/usr/local/bin/mountbox
test -x $mountbox_prog && mountbox_entry=$(entry \
    $ICONS/mountbox.png \
    "mountbox &" \
    $"Mount Connected Devices")

liveusb_prog_g=/usr/local/bin/live-usb-maker-gui
liveusb_prog=/usr/local/bin/live-usb-maker
if test -x $liveusb_prog_g; then
liveusb_entry=$(entry \
    $ICONS/usb-creator.png \
    "gksu live-usb-maker-gui &" \
    $"Install to USB")

elif test -x $liveusb_prog; then
liveusb_entry=$(entry \
    $ICONS/usb-creator.png \
     "desktop-defaults-run sudo &live-usb-maker &" \
    $"Install to USB")
fi

partimage_prog=/usr/sbin/partimage
test -x $partimage_prog && partimage_entry=$(entry \
    $ICONS/drive-harddisk-system.png \
    "desktop-defaults-run -t sudo partimage &" \
    $"Image a Partition")

grsync_prog=/usr/bin/grsync
test -x $grsync_prog && grsync_entry=$(entry \
    $ICONS/grsync.png \
    "grsync &" \
    $"Synchronize Directories")

gparted_prog=/usr/sbin/gparted
test -x $gparted_prog && gparted_entry=$(entry \
    $ICONS/gparted.png \
    "gksu gparted &" \
    $"Partition a Drive")

setdpi_prog=/usr/local/bin/set-dpi
test -x $setdpi_prog && setdpi_entry=$(entry \
    $ICONS/fonts.png \
    "set-dpi &" \
    "$dpi_label")

inxi_prog=/usr/local/bin/inxi-gui
test -x $inxi_prog && inxi_entry=$(entry \
    $ICONS2/info_blue.png \
    "inxi-gui &" \
    $"PC Information")

mouse_prog=/usr/local/bin/ds-mouse
test -x $mouse_prog && mouse_entry=$(entry \
    $ICONS/input-mouse.png \
    "ds-mouse &" \
    $"Configure Mouse")

soundcard_prog=/usr/local/bin/alsa-set-default-card
test -x $soundcard_prog && soundcard_entry=$(entry \
    $ICONS2/soundcard.png \
    "alsa-set-default-card &" \
    $"Set Default Sound Card")

mixer_prog=/usr/bin/alsamixer
test -x $mixer_prog && mixer_entry=$(entry \
    $ICONS/audio-volume-high-panel.png \
    "desktop-defaults-run -t alsamixer &" \
    $"Adjust Mixer")

ddm_prog=/usr/local/bin/ddm-mx
test -x $ddm_prog && atidriver_entry=$(entry \
    $ICONS2/amd-ddm-mx.png \
    "desktop-defaults-run -t su-to-root -c '/usr/local/bin/ddm-mx -i ati' &" \
    $"AMD/ATI fglrx Driver Installer")

test -x $ddm_prog && nvdriver_entry=$(entry \
    $ICONS2/nvidia-ddm-mx.png \
    "desktop-defaults-run -t su-to-root -c '/usr/local/bin/ddm-mx -i nvidia' &" \
    $"Nvidia Driver Installer")

ndiswrapper_prog=/usr/sbin/ndisgtk
test -x $ndiswrapper_prog && ndiswrapper_entry=$(entry \
    $ICONS/computer.png \
    "gksu /usr/sbin/ndisgtk &" \
    $"MS Windows Wireless Drivers")

snapshot_prog=/usr/bin/isosnapshot
test -x $snapshot_prog && snapshot_entry=$(entry \
    $ICONS/preferences-system.png \
    "gksu isosnapshot &" \
    $"Create Snapshot(ISO)")

soundtest_prog=/usr/bin/speaker-test
test -x $soundtest_prog  && soundtest_entry=$(entry \
    $ICONS/preferences-desktop-sound.png \
    "urxvt -e speaker-test --channels 2 --test wav --nloops 3 &" \
    $"Test Sound")

menumanager_prog=/usr/local/bin/menu_manager.sh
test -x $menumanager_prog && menumanager_entry=$(entry \
    $ICONS2/menu_manager.png \
    "sudo menu_manager.sh &" \
    $"Edit menus")

usermanager_prog=/usr/local/bin/user-management
test -x $usermanager_prog && usermanager_entry=$(entry \
    $ICONS/config-users.png \
    "gksu user-management &" \
    $"User Manager")

galternatives_prog=/usr/bin/galternatives
test -x $galternatives_prog && galternatives_entry=$(entry \
    $ICONS2/galternatives.png \
    "galternatives &" \
    $"Alternatives Configurator")

codecs_prog=/usr/sbin/codecs
test -x $codecs_prog && codecs_entry=$(entry \
    $ICONS/applications-system.png \
    "su-to-root -X -c codecs &" \
    $"Install Restricted Codecs")

broadcom_prog=/usr/sbin/broadcom-manager
test -x $broadcom_prog && broadcom_entry=$(entry \
    $ICONS/palimpsest.png \
    "su-to-root -X -c broadcom-manager &" \
    $"Network Troubleshooting")

[ -e /etc/live/config/save-persist -o -e /etc/live/config/persist-save.conf ]  && persist_save=$(entry \
    $ICONS/palimpsest.png \
    "gksu persist-save &" \
    $"Save root persistence")

[ -e /etc/live/config/remasterable -o -e /etc/live/config/remaster-live.conf ] && live_remaster=$(entry \
    $ICONS/preferences-desktop.png \
    "gksu live-remaster &" \
    $"Remaster-Customize Live")

live_tab=$(cat<<Live_Tab
<vbox> <frame> <hbox>
  <vbox>
$(entry "$ICONS/remastersys.png" "gksu persist-config &" $"Configure live persistence")
$livekernel_entry
$bootloader_entry
$persist_save
  </vbox>
  <vbox>
$(entry $ICONS/palimpsest.png "gksu persist-makefs &" $"Set up live persistence")
$excludes_entry
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

export ControlCenter=$(cat<<Control_Center
<window title="antiX Control Center" icon="gnome-control-center" window-position="1">
  <vbox>
<notebook tab-pos="0" labels="$tab_labels">
<vbox> <frame> <hbox>
  <vbox>
$wallpaper_entry
$icewm_entry
$jwm_entry
$conky_entry
  </vbox>
  <vbox>
$setdpi_entry
$lxappearance_entry
$fluxbox_entry
$prefapps_entry
  </vbox>
</hbox> </frame> </vbox>
<vbox> <frame> <hbox>
  <vbox>
$synaptic_entry
$packageinstaller_entry
$sysvconf_entry
$galternatives_entry
  </vbox>
  <vbox>
$confroot_entry
$fskbsetting_entry
$tzdata_entry
  </vbox>
</hbox> </frame> </vbox>
<vbox> <frame> <hbox>
  <vbox>
$ceni_entry
$umts_entry
$wicd_entry
$pppoeconf_entry
  </vbox>
  <vbox>
$gnomeppp_entry
$wpasupplicant_entry
$firewall_entry
$adblock_entry
  </vbox>
</hbox> </frame></vbox>
<vbox> <frame> <hbox>
  <vbox>
$connectshares_entry
$droopy_entry
  </vbox>
  <vbox>
$disconnectshares_entry
$samba_entry
  </vbox>
</hbox> </frame></vbox>
<vbox> <frame> <hbox>
  <vbox>
$lxkeymap_entry
$slim_entry
$arandr_entry
$grub_entry
  </vbox>
  <vbox>
$gksu_entry
$slimlogin_entry
$screenblank_entry
$desktopsession_entry
  </vbox>
</hbox> </frame> </vbox>
$live_tab
<vbox> <frame> <hbox>
  <vbox>
$automount_entry
$mountbox_entry
$unetbootin_entry
  </vbox>
  <vbox>
$liveusb_entry
$partimage_entry
$grsync_entry
$gparted_entry
  </vbox>
</hbox> </frame> </vbox>
<vbox> <frame> <hbox>
  <vbox>
$printer_entry
$inxi_entry
$mouse_entry
  </vbox>
  <vbox>
$soundcard_entry
$soundtest_entry
$mixer_entry
$equalizer_entry
  </vbox>
</hbox> </frame> </vbox>
<vbox> <frame> <hbox>
  <vbox>
$nvdriver_entry
$atidriver_entry
$codecs_entry
  </vbox>
  <vbox>
$ndiswrapper_entry
  </vbox>
</hbox> </frame> </vbox>
<vbox> <frame> <hbox>
  <vbox>
$snapshot_entry
$backup_entry
$broadcom_entry
  </vbox>
  <vbox>
$bootrepair_entry
$menumanager_entry
$usermanager_entry
  </vbox>
</hbox> </frame> </vbox>
</notebook>
</vbox>
</window>
Control_Center
)

#echo "$ControlCenter"

gtkdialog --program=ControlCenter
#unset ControlCenter
