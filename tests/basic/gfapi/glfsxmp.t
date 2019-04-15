#!/bin/bash

. $(dirname $0)/../../include.rc
. $(dirname $0)/../../volume.rc

cleanup

TEST glusterd

TEST $CLI volume create $V0 replica 3 $H0:$B0/brick{0,1,2}
EXPECT 'Created' volinfo_field $V0 'Status'

TEST $CLI volume start $V0
EXPECT 'Started' volinfo_field $V0 'Status'

# It is good to copy the file locally and build it, so the scope remains
# inside tests directory.
TEST cp $(dirname ${0})/../../../api/examples/glfsxmp.c glfsxmp.c
TEST build_tester ./glfsxmp.c -lgfapi

TEST ./glfsxmp $V0 $H0

cleanup_tester ./glfsxmp

TEST rm ./glfsxmp.c

TEST $CLI volume stop $V0
TEST $CLI volume delete $V0

cleanup
