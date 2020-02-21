#!/bin/bash
export PREFIX=/opt/sgug
export DISTCCD_PATH="${PREFIX}/mips-sgi-irix6.5/bin" 
distccd \
    --daemon \
    --no-detach \
    --port 8086 \
    --stats \
    --stats-port 8186 \
    --log-stderr \
    --listen 0.0.0.0 \
    --allow 0.0.0.0/0 \
    --verbose