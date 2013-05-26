#!/bin/sh

# PROVIDE: jailadmin
# REQUIRE: openvpn mysql apache22

old_path="${PATH}"

PATH="${PATH}:/usr/local/bin:/usr/local/sbin"
export PATH

site_path="/www/shawn-vm-host.work.0xfeedface.org"

. /etc/rc.subr

name="ngjail"
pidfile="/var/run/${name}.pid"
start_cmd="jailadmin_start_jails"
stop_cmd="jailadmin_stop_jails"
restart_cmd="jailadmin_restart_jails"
pidfile="/var/run/${name}.pid"

jailadmin_start_jails() {
    /usr/local/bin/drush -r ${site_path} autoboot
    echo $! > ${pidfile}
}

jailadmin_stop_jails() {
    if [ ! -f ${pidfile} ]; then
        return 1
    fi

    /usr/local/bin/drush -r ${site_path} stopall

    rm -f ${pidfile}
}

jailadmin_restart_jails() {
    jailadmin_stop_jails
    jailadmin_start_jails
}

load_rc_config $name
run_rc_command "$1"

PATH="${old_path}"
export PATH
