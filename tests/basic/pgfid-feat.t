#!/bin/bash

. $(dirname $0)/../include.rc
. $(dirname $0)/../volume.rc

cleanup;

function get_ancestry_path() {
	local path=$1
	local ancestry=$(getfattr --absolute-names -e text -n glusterfs.ancestry.path "$M0/$path" | grep "^glusterfs.ancestry.path" | cut -d"=" -f2 | tr -d \");
	echo $ancestry;
}

TEST glusterd
TEST pidof glusterd
TEST $CLI volume info;

TEST $CLI volume create $V0 replica 2  $H0:$B0/${V0}{1,2,3,4};
TEST $CLI volume start $V0;
TEST glusterfs -s $H0 --volfile-id $V0 $M0;

TEST $CLI volume set $V0 build-pgfid on;

TEST mkdir $M0/a;
TEST touch $M0/a/b;

getfattr -e text -n glusterfs.ancestry.path "$M0/a/b" | grep "^glusterfs.ancestry.path" | cut -d"=" -f2 | tr -d \";
EXPECT "/a/b" get_ancestry_path "/a/b";

TEST $CLI volume set $V0 build-pgfid off;
TEST ! getfattr -e text -n "glusterfs.ancestry.path" $M0/a/b;

TEST $CLI volume stop $V0;
TEST $CLI volume delete $V0;

cleanup;
