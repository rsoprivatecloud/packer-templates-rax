#!/bin/bash
set -x

yum clean all

rm -f /etc/ssh/*key*

rm -rf /tmp/*

rm -rf /var/log/wtmp /var/log/btmp

history -c
