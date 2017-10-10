#!/usr/bin/env bash
breed=$1
if [[ $EUID -ne 0 ]]; then
  pre_command='sudo '
else
  pre_command=''
fi
which tput >/dev/null 2>&1
if [ "x${?}" == "x0" ]; then
  SETCOLOR_NORMAL=$(tput sgr0)
  SETCOLOR_TITLE=$(tput setaf 6)
  SETCOLOR_BOLD=$(tput setaf 15)
else
  SETCOLOR_NORMAL=""
  SETCOLOR_TITLE=""
  SETCOLOR_BOLD=""
fi
echo_title () {
  echo
  echo "${SETCOLOR_BOLD}###${SETCOLOR_NORMAL} ${SETCOLOR_TITLE}${1}${SETCOLOR_NORMAL} ${SETCOLOR_BOLD}###${SETCOLOR_NORMAL}"
}

update_redhat() {
  echo_title "Upgrading packages on RedHat"
  $pre_command yum update -y 
}

update_fedora() {
  echo_title "Upgrading packages on Fedora"
  $pre_command yum update -y 
}

update_suse() {
  echo_title "Upgrading packages on Suse"
  $pre_command zypper update --non-interactive
}

update_apt() {
  echo_title "Upgrading packages on Debian and derivates"
  $pre_command apt-get update
  $pre_command apt-get upgrade -y
}
update_alpine() {
  echo_title "Upgrading packages on Alpine"
  $pre_command apk update
  $pre_command apk upgrade
}
update_solaris() {
  echo_title "Not yet supported"
}
update_darwin() {
  echo_title "Not yet supported"
}
update_bsd() {
  echo_title "Upgrading packages on FreeBSD"
  $pre_command freebsd-update fetch
  $pre_command freebsd-update install
}
update_windows() {
  echo_title "Not yet supported"
}
update_linux() {
  ARCH=$(uname -m | sed 's/x86_//;s/i[3-6]86/32/')
  if [ -f /etc/redhat-release ]; then
      OS=$(cat /etc/redhat-release | cut -d ' ' -f 1-2 | tr -d '[:space:]')
      if [ "$OS" == "CentOSLinux" ] || [ "$OS" == "CentOSrelease" ] ; then
        OS="CentOS"
      fi
      majver=$(cat /etc/redhat-release | sed 's/[^0-9\.]*//g' | sed 's/ //g' | cut -d '.' -f 1)
  elif [ -f /etc/SuSE-release ]; then
      OS=sles
      majver=$(cat /etc/SuSE-release | grep VERSION | cut -d '=' -f 2 | tr -d '[:space:]')
  elif [ -f /etc/alpine-release ]; then
      OS=alpine
      majver=$(cat /etc/alpine-release | cut -d '.' -f 1)
  elif [ -f /etc/os-release ]; then
      . /etc/os-release
      OS=$ID
      majver=$VERSION_ID
  elif [ -f /etc/debian_version ]; then
      OS=Debian
      majver=$(cat /etc/debian_version | cut -d '.' -f 1)
  elif [ -f /etc/lsb-release ]; then
      . /etc/lsb-release
      OS=$DISTRIB_ID
      majver=$DISTRIB_RELEASE
  elif [ -f /etc/os-release ]; then
      . /etc/os-release
      OS=$ID
      majver=$VERSION_ID
  else
      OS=$(uname -s)
      majver=$(uname -r)
  fi
  distro=$(echo $OS | tr '[:upper:]' '[:lower:]')
  echo_title "Detected Linux distro: ${distro} version ${majver} on arch ${ARCH}"
  case "$distro" in
    debian) update_apt $majver ;;
    ubuntu) update_apt $majver ;;
    redhat) update_redhat $majver ;;
    fedora) update_fedora $majver ;;
    centos) update_redhat $majver ;;
    scientific) update_redhat $majver ;;
    amazon) update_redhat $majver ;;
    sles) update_suse $majver ;;
    cumulus-linux) update_apt $majver ;;
    alpine) update_alpine $majver ;;
    *) echo "Not supported distro: $distro" ;;
  esac
}

os_detect() {
  case "$OSTYPE" in
    solaris*) update_solaris ;;
    darwin*)  update_darwin ;;
    linux*)   update_linux ;;
    bsd*)     update_bsd ;;
    cygwin*)  update_windows ;;
    msys*)    update_windows ;;
    win*)     update_windows ;;
    *)        update_linux ;; # For alpine
  esac
}

if [ "x$breed" != "x" ]; then
  update_$breed
else
  os_detect
fi

