#!/bin/sh
#

# PROVIDE: ipv6_tunnel
# REQUIRE: openvpn

. /etc/rc.subr

name="ipv6_tunnel"
pidfile="/var/run/${name}.pid"
start_cmd="start_tunnel"
stop_cmd="stop_tunnel"
restart_cmd="restart_tunnel"
pidfile="/var/run/${name}.pid"

start_tunnel() {
    if [ -f ${pidfile} ]; then
        echo "Already started? ${pidfile} shows pid of: $(cat ${pidfile})"
        return 1
    fi

    while true; do
        ping -c 1 192.168.3.1 > /dev/null 2>&1
        if [ $? == 0 ]; then
            break
        fi
    done

    route add -host 72.52.104.74 192.168.3.1
    ifconfig gif0 create
    ifconfig gif0 tunnel $(ifconfig | grep 192.168.3 | awk '{print $2;}' | head -n 1) 72.52.104.74
    ifconfig gif0 inet6 2001:470:1f04:1a28::2 2001:470:1f04:1a28::1 prefixlen 128
    ifconfig gif0 inet6 2001:470:8142::1/64
    route -n add -inet6 default 2001:470:1f04:1a28::1
    ifconfig gif0 up
    ifconfig bge0 inet6 2001:470:8142:2::1/64
    sleep 1
    ping6 -i 15 0xfeedface.org > /dev/null 2>&1 &
    echo $! > ${pidfile}
}

stop_tunnel() {
    if [ ! -f ${pidfile} ]; then
        echo "Tunnel not online."
        return 1
    fi

    route del 72.52.104.74
    route del -inet6 default
    ifconfig gif0 destroy
    kill $(cat ${pidfile})
    rm -f ${pidfile}
}

restart_tunnel() {
    stop_tunnel
    start_tunnel
}

load_rc_config $name
run_rc_command "$1"
