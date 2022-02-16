#!/bin/bash
#set -eux
set -euxv

# Script to busybox shell scripts only for commands are missing on the system 

PRG=busybox-script-installer

# ${parameter:-word} # If parameter is unset or null, the expansion of word is substituted. Otherwise, the value of parameter is substituted. https://pubs.opengroup.org/onlinepubs/009695399/utilities/xcu_chap02.html#tag_02_06_02
DEBUG=${DEBUG:-0}

debug()
{
        if [ $DEBUG -eq 1 ] ; then
                echo -e "DEBUG: $@"
        else
                "$@"
        fi
}

create_busybox_links()
{
# Create busybox links
BUSYBOX_BINARY=`find $ROOT_DIR -name "busybox*"`
echo "$BUSYBOX_BINARY"
BUSYBOX_TMP=$(mktemp -d -p $ROOT_DIR)
mkdir -p $BUSYBOX_TMP/bin

${BUSYBOX_BINARY} --install -s $BUSYBOX_TMP/bin/
rsync -l --ignore-existing $BUSYBOX_TMP/bin/* $ROOT_DIR/bin/
if [ $DEBUG -lq 1 ] ; then rm -rf $BUSYBOX_TMP ; fi
for l in $ROOT_DIR/bin/*; do
  if test -h $l; then
    ln -sf /sbin/busybox-static $l
  fi
done
}

create_busybox_scripts()
{
local BUSYBOX_FILE_NAME=$1
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:$PATH command -v $BUSYBOX_FILE_NAME && create_busybox_scripts_doit $BUSYBOX_FILE_NAME  ||:
}

create_busybox_scripts_doit()
{

local BUSYBOX_FILE_NAME=$1

# Create busybox links
# https://wiki.debian.org/ReduceDebian
# make shure to have a working search PATH env
PATH="$PATH:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
ROOT_DIR=/usr/local/bin
BUSYBOX_BINARY=`PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:$PATH command -v $BUSYBOX_FILE_NAME || return 0`
echo "BUSYBOX_BINARY $BUSYBOX_BINARY"
#BUSYBOX_TMP=$(mktemp -d -p $ROOT_DIR)
BUSYBOX_TMP=$(mktemp -d -t $PRG-tmp.XXXXXX)
mkdir -p $BUSYBOX_TMP/bin

${BUSYBOX_BINARY} --install -s $BUSYBOX_TMP/bin/
rsync -l --ignore-existing $BUSYBOX_TMP/bin/* $ROOT_DIR/bin/
rm -rf $BUSYBOX_TMP
for l in $ROOT_DIR/bin/*; do
  if test -h $l; then
    ln -sf /sbin/busybox-static $l
  fi
done
}

create_busybox_scripts busybox.static
create_busybox_scripts busybox-static
create_busybox_scripts busybox-extras
create_busybox_scripts busybox.extras
create_busybox_scripts busybox
