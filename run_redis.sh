#!/bin/bash

if [ "$1" = "-h" ]; then
	echo "./run_redis.sh run"
	echo "./run_redis.sh clean"
	exit 0
fi

redis_run() {
	port=$1
	aof=$2
	conf_file=redis_$port.conf
	if [ ! -f "redis_$port.conf" ]; then
		cp redis.conf redis_$port.conf
		mkdir $port
		sed -i "s/^daemonize.*/daemonize yes/g" $conf_file
		sed -i "s/^protected-mode.*/protected-mode no/g" $conf_file
		sed -i "s/6379/$port/g" $conf_file
		sed -i "s/^bind.*/#&/g" $conf_file
		sed -i "s/^dir.*/&$port\//g" $conf_file
		sed -i "/nvm/d;/pointer/d" $conf_file
		if [ "$aof" = "noaof" ]
		then
			sed -i "s/^appendonly.*/appendonly no/g" $conf_file
		else
			sed -i "s/^appendonly.*/appendonly yes/g" $conf_file
			sed -i "s/^appendfsync.*/appendfsync always/g" $conf_file
		fi
		if [ -d "/mnt/pmem0" ]
		then
			sed -i '$a\nvm-maxcapacity 1' $conf_file
			sed -i '$a\nvm-dir \/mnt\/pmem0' $conf_file
			sed -i '$a\nvm-threshold 64' $conf_file
			sed -i '$a\pointer-based-aof yes' $conf_file
			touch /mnt/pmem0/redis-port-$port-1GB-AEP
			dd if=/dev/zero of=/mnt/pmem0/redis-port-$port-1GB-AEP bs=1024k count=1024 >/dev/null 2>&1
		fi
	fi
	cpu=`echo "$port - 6379" | bc`
	taskset -c $cpu redis-server $conf_file >/dev/null 2>&1
}

redis_clean() {
	port=$1
	aof=$2
	conf_file=redis_$port.conf
	redis-cli -p $port shutdown
	rm -rf $port $conf_file
	if [ -d "/mnt/pmem0" ]; then
		rm -rf /mnt/pmem0/redis*
	fi
}


Operation=$1 #clean or run
######################
# Run or Clean Redis #
######################
for port in $PORT_LIST
do
	# echo $port
	if [ "$Operation" = "run" ]; then
		redis_run $port $AOF
	fi
	if [ "$Operation" = "clean" ]; then
		redis_clean $port
	fi
done

