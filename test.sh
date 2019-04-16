#!/bin/bash

for i in {1..12}
do
	export INST_NUM=$i
	export TEST_NUM=3
	a=0
	for((j=1;j<=$TEST_NUM;j++))
	do
		b=`./redis_benchmark.sh`
		a=`echo "$a + $b" | bc`
	done
	echo "$a/$TEST_NUM" | bc
done
