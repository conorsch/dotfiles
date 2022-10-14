#!/bin/bash
set -e
/usr/bin/redshift -c /home/user/.config/redshift.conf \
	-t 5700:3600 -b 0.7:1.0 -v
