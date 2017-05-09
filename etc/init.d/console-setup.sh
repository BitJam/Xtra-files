#!/bin/sh
### BEGIN INIT INFO
# Provides:          console-setup.sh
# Required-Start:    $remote_fs
# Required-Stop:
# Should-Start:      console-screen kbd
# Default-Start:     2 3 4 5
# Default-Stop:
# X-Interactive:     true
# Short-Description: Set console font and keymap
### END INIT INFO

for param in $(cat /live/config/proc-cmdline /live/config/cmdline 2>/dev/null); do
    case "$param" in
                       lang=*) should_run=true ;;
        kbd=*|kbopt=*|kbvar=*) should_run=true ;;
    esac
done


if [ -f /bin/setupcon -a -n "$should_run" ]; then
    case "$1" in
        stop|status)
        # console-setup isn't a daemon
        ;;
        start|force-reload|restart|reload)
            if [ -f /lib/lsb/init-functions ]; then
                . /lib/lsb/init-functions
            else
                log_action_begin_msg () {
	            echo -n "$@... "
                }

                log_action_end_msg () {
	            if [ "$1" -eq 0 ]; then
	                echo done.
	            else
	                echo failed.
	            fi
                }
            fi
            log_action_begin_msg "Setting up console font and keymap"
            if /lib/console-setup/console-setup.sh; then
	        log_action_end_msg 0
	    else
	        log_action_end_msg $?
	    fi
	    ;;
        *)
            echo 'Usage: /etc/init.d/console-setup {start|reload|restart|force-reload|stop|status}'
            exit 3
            ;;
    esac

else

    case $1 in
        start) ;;
            *) exit 0 ;;
    esac

    # Set the console font based on values the file below. Try hard to get some
    # reasonable font

    file=/etc/default/console-setup
    fdir=/usr/share/consolefonts

    read live_font 2>/dev/null </live/config/font

    if test -r $file; then
        . $file

        if [ -z "$CODESET" -o "$CODESET" = "guess" ]; then
            case ${lang%%_*} in
                             kk|ky|tj) code='CyrAsia'  ;;
                                ru|uk) code='CyrKoi'   ;;
                          bg|mk|ru|sr) code='CyrSlav'  ;;
              bs|hr|cs|hu|pl|ro|sk|sl) code='Lat2'     ;;
                af|sq|ast|da|nl|et|fr) code='Lat15'    ;;
            'fi'|de|is|id|pt|es|sv|tr) code='Lat15'    ;;
                                lt|lv) code='Lat7'     ;;
                                   el) code='Greek'    ;;
                                    *) code='Uni2'     ;;
            esac

        else
            code=$CODESET
        fi

        ext=.psf.gz

        font=
        for try in $FONT $code-$FONTFACE$FONTSIZE$ext $live_font$ext $code-VGA16$ext; do
            #echo $try
            test -e $fdir/$try || continue
            font=$try
            break
        done
    fi

    : ${font:=Uni2-VGA16}

    : ${ACTIVE_CONSOLES:=/dev/tty[1-6]}

    . /lib/lsb/init-functions

    log_action_begin_msg "Setting console font to ${font%$ext}"

    ret=0

    for tty in $ACTIVE_CONSOLES; do
        setfont -C $tty $font || ret=$?
    done

    log_action_end_msg $ret
    exit $ret
fi
