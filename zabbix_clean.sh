#!/bin/bash

#ps -eoetime=,pid=,cmd= | awk 'int(substr($1,1,index($1,"-"))) >= 21 { print }'|egrep "calculation|simulation|analysis"|egrep -v "python|grep|bash"|awk '{ print $2 }'
oldprocess=$(ps -eoetime=,pid=,cmd= | awk 'int(substr($1,1,index($1,"-"))) >= 21 { print }'|egrep "calculation|simulation|analysis"|egrep -v "python|grep|bash"|awk '{ print $2 }')
echo $oldprocess
for i in $oldprocess
do 
	echo  $i

done

