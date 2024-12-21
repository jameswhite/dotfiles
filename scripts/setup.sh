#!/bin/bash
[ ! -f ${LOGNAME}/bin ] && mkdir -p ${LOGNAME}/bin
$(dirname $0)/../home/bin/dotmanage -i
