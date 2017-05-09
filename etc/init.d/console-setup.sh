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

    font=
    read font 2>/dev/null </live/config/font
    : ${font:=Uni2-VGA16}

    . /lib/lsb/init-functions

    log_action_begin_msg "Setting console font to $font"

    ret=0

    for n in 1 2 3 4 5 6; do
        tty=/dev/tty$n
        test -e $tty || continue
        setfont -C $tty $font || ret=$?
    done

    log_action_end_msg $ret
    exit $ret
fi
