#!/bin/bash

export exedir=${1}

cd $exedir/GIGC_code_mirror/

make clean || exit 1

find ./ -name "*.o" -exec rm "{}" \;
find ./ -name "*.mod" -exec rm "{}" \;
find ./ -name "*.a" -exec rm "{}" \;

exit 0
