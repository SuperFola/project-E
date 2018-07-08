#!/bin/bash

if [ "$#" -eq "1" ]; then
    unetbootin lang=en method=diskimage imgfile=build/project_e.img installtype=USB targetdrive=$1 nodistro=y autoinstall=yes
else
    echo "Need a single argument : the disk where the ISO should be deployed" && exit 1
fi
