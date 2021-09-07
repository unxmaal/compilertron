#!/bin/bash

# If /opt/irix is present but is empty, it's a mounted volume.  Copy the contents
# of irix-base in to expose it to the host.
if [ -d /opt/irix -a ! -d /opt/irix/sgug ] ; then
    echo "Setting up external mounted /opt/irix"
    echo "Copying files into /opt/irix, please wait..."
    rsync -a --info=progress2 --info=name0 /opt/irix-base/ /opt/irix
elif [ ! -d /opt/irix ] ; then
    echo "Setting up in-container /opt/irix"
    ln -s /opt/irix-base /opt/irix
fi

if [ ! -d /opt/irix/sgug ] ; then
    echo "Looks like /opt/irix exists but it didn't get set up properly?"
    exit 1
fi

echo Starting distccd
export PREFIX=/opt/irix/sgug
export DISTCCD_PATH="${PREFIX}/mips-sgi-irix6.5/bin" 
distccd \
    --daemon \
    --no-detach \
    --stats \
    --stats-port 8186 \
    --log-stderr \
    --listen 0.0.0.0 \
    --allow 0.0.0.0/0 \
    --verbose

