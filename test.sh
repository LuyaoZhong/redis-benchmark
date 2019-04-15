#!/bin/bash

for i in {1..12}
do
	export INST_NUM=$i
	./redis_benchmark.sh
done
