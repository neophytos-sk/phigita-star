#!/bin/bash
tar -hcf /web/distfiles/profile-${1}.tar /web/profiles/${1}
bzip2 /web/distfiles/profile-${1}.tar
