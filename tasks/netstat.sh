#!/usr/bin/env bash
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
declare options
options="--detailed-exitcodes"
case $PT_show in
  "all")
    options="-a"
    ;;
  "route")
    options="-r"
    ;;
  "interfaces")
    options="-i"
    ;;
  "statistics")
    options="-s"
    ;;
  "groups")
    options="-a"
    ;;
  "listening")
    options="-l"
    ;;
esac

case $PT_socket in
  "all")
    options="${options}"
    ;;
  "tcp")
    options="${options}t"
    ;;
  "udp")
    options="${options}u"
    ;;
  "raw")
    options="${options}w"
    ;;
  "unix")
    options="${options}x"
    ;;
esac

[[ "${PT_resolve}" == "true" ]] && options="${options}n"
[[ "${PT_extend}" == "true" ]] && options="${options}e"
[[ -n "${PT_custom}" ]] && options="${PT_custom}"

readonly options

netstat $options
