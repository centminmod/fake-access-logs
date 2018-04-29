#!/bin/bash
#########################################################
# written by George Liu (eva2000) https://centminmod.com
#########################################################
# variables
#############
DT=$(date +"%d%m%y-%H%M%S")
ACCESSLOG_NAMEA='access_log_20180428-234724.log.gz'
ACCESSLOG_NAMEB='access_log_20180429-005239.log.gz'
ACCESSLOG_NAMEC='access_log_20180429-012648.log.gz'
DIR_TEST='/home/zcat-test'

#########################################################
# functions
#############
if [ ! -d "$DIR_TEST" ]; then
  mkdir -p "$DIR_TEST"
fi

if [[ ! -f /usr/bin/pigz && -f /usr/bin/yum ]]; then
  yum -y -q install pigz
elif [[ ! -f /usr/bin/pigz && -f /usr/bin/apt-get ]]; then
  apt-get update
  apt-get -y install pigz
fi

parallel_install() {
  # ls *.log.gz | parallel "(zcat {} | wc -l)"
  # ls *.log.gz | time parallel "(zcat {})" | wc -l
  if [ ! -f /usr/bin/parallel ]; then
    yum -y -q install parallel
    mkdir -p ~/.parallel
    touch ~/.parallel/will-cite
  fi
}

download_files() {
  if [ -d "$DIR_TEST" ]; then
    cd "$DIR_TEST"
    if [ ! -f "${DIR_TEST}/${ACCESSLOG_NAMEA}" ]; then
      wget -q -O "${DIR_TEST}/${ACCESSLOG_NAMEA}" https://github.com/centminmod/fake-access-logs/raw/master/logs/access_log_20180428-234724.log.gz
    fi
    if [ ! -f "${DIR_TEST}/${ACCESSLOG_NAMEB}" ]; then
      wget -q -O "${DIR_TEST}/${ACCESSLOG_NAMEB}" https://github.com/centminmod/fake-access-logs/raw/master/logs/access_log_20180429-005239.log.gz
    fi
    if [ ! -f "${DIR_TEST}/${ACCESSLOG_NAMEC}" ]; then
      wget -q -O "${DIR_TEST}/${ACCESSLOG_NAMEC}" https://github.com/centminmod/fake-access-logs/raw/master/logs/access_log_20180429-012648.log.gz
    fi
  fi
}

clean_up() {
  if [ -d "$DIR_TEST" ]; then
    if [ -f "${DIR_TEST}/${ACCESSLOG_NAMEA}" ]; then
      rm -rf "${DIR_TEST}/${ACCESSLOG_NAMEA}"
    fi
    if [ -f "${DIR_TEST}/${ACCESSLOG_NAMEB}" ]; then
      rm -rf "${DIR_TEST}/${ACCESSLOG_NAMEB}"
    fi
    if [ -f "${DIR_TEST}/${ACCESSLOG_NAMEC}" ]; then
      rm -rf "${DIR_TEST}/${ACCESSLOG_NAMEC}"
    fi
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
  echo "zcat "$ACCESSLOG_NAMEA" "$ACCESSLOG_NAMEB" "$ACCESSLOG_NAMEC" | wc -l"
  /usr/bin/time --format='real: %es user: %Us sys: %Ss cpu: %P maxmem: %M KB cswaits: %w' zcat "$ACCESSLOG_NAMEA" "$ACCESSLOG_NAMEB" "$ACCESSLOG_NAMEC" | wc -l

}

test_pzcat() {
  if [[ "$(nproc)" -ge '2' && ! -f /usr/bin/pzcat && -f /usr/bin/zcat && -f /usr/bin/pigz ]]; then \cp -af /usr/bin/zcat /usr/bin/pzcat; sed -i 's|exec gzip -cd|exec pigz -cd|' /usr/bin/pzcat; fi
  if [ -f /usr/bin/pzcat ]; then
    download_files
    clear_it
    cd "$DIR_TEST"
    echo "pzcat "$ACCESSLOG_NAMEA" "$ACCESSLOG_NAMEB" "$ACCESSLOG_NAMEC" | wc -l"
    /usr/bin/time --format='real: %es user: %Us sys: %Ss cpu: %P maxmem: %M KB cswaits: %w' pzcat "$ACCESSLOG_NAMEA" "$ACCESSLOG_NAMEB" "$ACCESSLOG_NAMEC" | wc -l
  
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
    clean_up
    ;;
  pzcat )
    test_pzcat
    clean_up
    ;;
  all )
    test_zcat
    echo
    test_pzcat
    clean_up
    ;;
  pattern )
    ;;
  pattern )
    ;;
  * )
    echo
    echo "$0 {zcat|pzcat|all}"
    echo
    ;;
esac
exit
