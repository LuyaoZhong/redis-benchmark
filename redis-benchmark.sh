#!/bin/bash

REQ_NUM=1000000 # -n
DATA_SIZE=1024
KEYSPACELEN=2000000 # -r
TEST=set
CLIENTS=100 # -c

#./src/redis-benchmark -p 6379 -t set -n 1000000 -r 2000000 -d 1024 -c 100 -P 10 -q

PORT_LIST=`seq 6379 6383`
# for port in $PORT_LIST
# do
# 	redis-cli -p $port flushall
# done

for port in $PORT_LIST
do
	{
    result=`redis-benchmark -p $port \
		-t $TEST \
		-n $REQ_NUM \
		-d $DATA_SIZE \
		-r $KEYSPACELEN \
		-c $CLIENTS \
		-P 10 \
		-q --csv \
		| cut -d ',' -f2 | cut -d '"' -f2`
	echo $result >> tmp.txt
	} &
done

wait

qps=0
inst=0
while read line
do
	qps=`echo "$line + $qps" | bc`
	echo $line
	inst=`echo "$inst + 1" | bc`
done < tmp.txt
rm -rf tmp.txt

echo "qps=$qps inst=$inst"
echo "----Tests Done----"
