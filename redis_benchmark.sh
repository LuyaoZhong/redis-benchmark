#!/bin/bash

REQ_NUM=1000000 # -n
DATA_SIZE=1024
KEYSPACELEN=2000000 # -r
TEST=set
CLIENTS=100 # -c

# example:
# ./src/redis-benchmark -p 6379 -t set -n 1000000 -r 2000000 -d 1024 -c 100 -P 10 -q

# set PORT_LIST and AOF env
source ./env

# for port in $PORT_LIST
# do
# 	redis-cli -p $port flushall
# done


###### Run Redis Instances ######
./run_redis.sh run


###### Redis Benchmark ######
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
	# echo $line
	qps=`echo "$line + $qps" | bc`
	inst=`echo "$inst + 1" | bc`
done < tmp.txt
rm -rf tmp.txt

echo "qps=$qps inst=$inst"
echo "----Tests Done----"


###### Clean Redis Instances ######
./run_redis.sh clean
