#!/bin/bash
. /container.env
/usr/bin/perl /opt/rt4/bin/rt-mailgate --url http://${RT_URL} --queue "${1}" --action ${2}
