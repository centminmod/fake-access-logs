#!/bin/bash
#########################################################
# written by George Liu (eva2000) https://centminmod.com
#########################################################
# variables
#############
DT=$(date +"%d%m%y-%H%M%S")
ACCESSLOG_NAME='access_log_20180428-234724.log.gz access_log_20180429-005239.log.gz access_log_20180429-012648.log.gz'
DIR_TEST='/home/zcat-test'

#########################################################
# functions
#############
if [ ! -d "$DIR_TEST" ]; then
  mkdir -p "$DIR_TEST"
fi

download_files() {
  if [[ -d "$DIR_TEST" && ! -f "${DIR_TEST}/access_log_20180428-234724.log.gz" ]]; then
    cd "$DIR_TEST"
    wget -q -O "${DIR_TEST}/access_log_20180428-234724.log.gz" https://github.com/centminmod/fake-access-logs/raw/master/logs/access_log_20180428-234724.log.gz
    wget -q -O "${DIR_TEST}/access_log_20180429-005239.log.gz" https://github.com/centminmod/fake-access-logs/raw/master/logs/access_log_20180429-005239.log.gz
    wget -q -O "${DIR_TEST}/access_log_20180428-234724.log.gz" https://github.com/centminmod/fake-access-logs/raw/master/logs/access_log_20180428-234724.log.gz
  fi
}

clear_it() {
  if [ ! -f /proc/user_beancounters ]; then
    sync && echo 3 > /proc/sys/vm/drop_caches
  fi
}

test_zcat() {
  download_files
  clear_it
  cd "$DIR_TEST"
  echo "/usr/bin/time --format='real: %es user: %Us sys: %Ss cpu: %P maxmem: %M KB cswaits: %w' zcat "$ACCESSLOG_NAME" | wc -l"
  /usr/bin/time --format='real: %es user: %Us sys: %Ss cpu: %P maxmem: %M KB cswaits: %w' zcat "$ACCESSLOG_NAME" | wc -l
}

test_pzcat() {
  if [[ "$(nproc)" -ge '2' && ! -f /usr/bin/pzcat && -f /usr/bin/zcat ]]; then \cp -af /usr/bin/zcat /usr/bin/pzcat; sed -i 's|exec gzip -cd|exec pigz -cd|' /usr/bin/pzcat; fi
  if [ -f /usr/bin/pzcat ]; then
    download_files
    clear_it
    cd "$DIR_TEST"
    echo "/usr/bin/time --format='real: %es user: %Us sys: %Ss cpu: %P maxmem: %M KB cswaits: %w' pzcat "$ACCESSLOG_NAME" | wc -l"
    /usr/bin/time --format='real: %es user: %Us sys: %Ss cpu: %P maxmem: %M KB cswaits: %w' pzcat "$ACCESSLOG_NAME" | wc -l
  else
    echo
    echo "system has less than 2 cpu threads so pigz based pzcat will have no benefit"
    echo
    exit
  fi
}

#########################################################
case $1 in
  zcat )
    test_zcat
    ;;
  pzcat )
    test_pzcat
    ;;
  pattern )
    ;;
  pattern )
    ;;
  pattern )
    ;;
  * )
    echo
    echo "$0 {zcat|pzcat}"
    echo
    ;;
esac
exit
