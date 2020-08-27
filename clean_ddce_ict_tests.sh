#!/bin/bash

ls -d /data/smith/*/ICT-Tests 2>/dev/null || exit 0

for i in `/bin/find /data/smith/*/ICT-Tests /data/smith/*/*/ICT-Tests -maxdepth 1 -mtime +30 -type d  | /bin/grep calc-`
do
        /bin/rm -rf $i
done

for i in `/bin/find /data/bjsmith/Calc /data/bjsmith/itesting/Calc -maxdepth 1 -mtime +30 -type d  | /bin/grep IAR`
do
        /bin/rm -rf $i
done

exit 0
