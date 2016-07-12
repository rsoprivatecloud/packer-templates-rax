#!/bin/bash
set -x

dd if=/dev/zero of=/EMPTY bs=1M
sync
rm -f /EMPTY
sync
