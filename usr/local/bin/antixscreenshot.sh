#! /bin/bash

TEXTDOMAINDIR=/usr/share/locale 
TEXTDOMAIN=antixscreenshot.sh

cd /home/$USER

function preview_full {
  feh -g 640x480 /home/$USER/scr/"$NAME"."$EXT" & yad --image="question" --title=$"antiXscreenshot" --text=$"Keep this screenshot?" --button="CANCEL:1" --button="OK:0"

  case "$?" in
  "0")
    killall feh
    
    if [ "$SAVETO" = "true" ] ; then
      choose_dir
    else
      dir_path=/home/$USER
      file_name="$NAME"
      file_ext="$EXT"
    
      save_shot
    fi
    ;;
  "1")
    killall feh
    rm -rf /home/$USER/scr
    ;;
  esac
}

function preview_custom {
  feh /home/$USER/scr/"$NAME"."$EXT" & yad --image="question" --title=$"antiXscreenshot" --text=$"Keep this screenshot?" --button="CANCEL:1" --button="OK:0";

  case "$?" in
  "0")
    killall feh
    
    if [ "$SAVETO" = "true" ] ; then
      choose_dir
    else
      dir_path=/home/$USER
      file_name="$NAME"
      file_ext="$EXT"
    
      save_shot
    fi
    ;;
  "1")
    killall feh
    rm -rf /home/$USER/scr
    ;;
  esac
}

function choose_dir {
  cd /home/$USER

  files=`yad --file-selection --save --filename="$NAME"."$EXT" --title="antiXscreenshot"` 
  
  if [ "$files" = "" ] ; then 
    rm -rf /home/$USER/scr
  else
    dir_path=`dirname "$files"`
    base_name=$(basename "$files")
    file_name=${base_name%.*}
    file_ext=${base_name##*.}
    
    if [ "$file_ext" != "$EXT" ] ; then
      yad --image="error" --title="antiXscreenshot" --text=$"File extension was changed.\nPlease try again."    
      choose_dir
    fi
    
    save_shot
  fi
}

function save_shot {
    if [ -e "$dir_path"/"$file_name"."$file_ext" ] ; then v=1
	while [ -e "$dir_path"/"$file_name"_"$v"."$file_ext" ] 
	do
	  echo $v
	  v=$(($v+1))
	done
	fi

    if [ -n "$v" ] ; then 
      mv /home/$USER/scr/"$NAME"."$EXT" "$dir_path"/"$file_name"_"$v"."$file_ext"	
      mv /home/$USER/scr/"$NAME"-thumb."$EXT" "$dir_path"/"$file_name"-thumb_"$v"."$file_ext"
    else 
      mv /home/$USER/scr/"$NAME"."$EXT" "$dir_path"/"$file_name"."$file_ext"
      mv /home/$USER/scr/"$NAME"-thumb."$EXT" "$dir_path"/"$file_name"-thumb."$file_ext"
    fi

    rm -rf /home/$USER/scr

    yad --title="antiXscreenshot" --image="info" --text=$"Your screenshot has been saved."
}

export DIALOG=$(cat <<End_of_Text 

<window title="antiXscreenshot" window-position="1">

<vbox>
<hbox>
  <vbox>
  <frame>
    <frame `gettext $"Region to capture"`>
    <combobox>
	  <variable>REGION</variable>
      <item>`gettext $"Full Screen"`</item>
      <item>`gettext $"Custom Area"`</item>
      <item>`gettext $"Window"`</item>
	</combobox>
    </frame>

    <frame `gettext $"Name of image"`>
    <entry>
      <default>screenshot</default>
      <variable>NAME</variable>
    </entry>
    </frame>

    <frame `gettext $"File type"`>
    <combobox>
      <variable>EXT</variable>
      <item>jpg</item>
      <item>png</item>
      <item>bmp</item>
      <item>xpm</item>
      <item>tif</item>
    </combobox>
    </frame>

    <frame `gettext $"Show save dialog"`>
    <checkbox active="true">
      <label>"`gettext $"Choose directory"`"</label>
      <variable>SAVETO</variable>
      <default>yes</default>
    </checkbox>
    </frame>
  </frame>
  </vbox>

  <vbox>
  <frame>
    <frame `gettext $"Delay in seconds"`>
    <entry>
      <default>5</default>
      <variable>DELAY</variable>
    </entry>
    </frame>

    <frame `gettext $"Multiple screenshots"`>
    <checkbox active="false">
      <label>"`gettext $"Take another shot"`"</label>
      <variable>AGAIN</variable>
      <default>no</default>
    </checkbox>
    </frame>

    <frame `gettext $"Thumbnail for webpages"`>
    <checkbox active="false">
      <label>"`gettext $"Create a thumbnail"`"</label>
      <variable>THUMB</variable>
      <default>no</default>
      <action>if true enable:PERC</action>
      <action>if false disable:PERC</action>
    </checkbox>
    <text use-markup="true" width-chars="20">
	<label>"`gettext $"Percentage (1-100)"`"</label>
	</text>
    <entry>
      <default>50</default>
      <variable>PERC</variable>
      <visible>disabled</visible>
    </entry>
    </frame>
  </frame>
  </vbox>
  </hbox>
  <hbox>
 	<button ok></button>
 	<button cancel></button>
  </hbox>
</vbox>

</window>
End_of_Text
)

I=$IFS; IFS=""
for STATEMENTS in  $(gtkdialog --program DIALOG); do
  eval $STATEMENTS
done
IFS=$I

if [ "$EXIT" = "OK" ] ; then
  mkdir /home/$USER/scr 

  if [ "$REGION" = $"Full Screen" ] ; then
    if [ "$THUMB" = "true" ] ; then
      scrot -t $PERC -d $DELAY $n /home/$USER/scr/"$NAME"."$EXT"
      preview_full
    else
      scrot -d $DELAY $n /home/$USER/scr/"$NAME"."$EXT"
      preview_full
    fi
  fi
  if [ "$REGION" = $"Custom Area" ] || [ "$REGION" = $"Window" ] ; then
    if [ "$THUMB" = "true" ] ;then
      scrot -s -b -t $PERC $n /home/$USER/scr/"$NAME"."$EXT"
      preview_custom
    else
      scrot -s -b $n /home/$USER/scr/"$NAME"."$EXT"
      preview_custom
    fi
  fi
  
  if [ "$AGAIN" = "true" ] ; then
    antixscreenshot.sh
  fi
fi
