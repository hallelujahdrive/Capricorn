#!/bin/bash

path=`dirname $0`
sizes_mini=(16 22 24)
sizes=(32 48 64 128 256)

for size in ${sizes_mini[@]}
do
	if [ ! -a ${path}/${size}x${size}/apps ];then
		mkdir -p ${path}/${size}x${size}/apps
	fi
	rsvg-convert ${path}/capricorn_mini.svg -h $size -w $size -f png -o ${path}/${size}x${size}/apps/capricorn.png
done

for size in ${sizes[@]}
do
	if [ ! -a ${path}/${size}x${size}/apps ];then
		mkdir -p ${path}/${size}x${size}/apps
	fi
	rsvg-convert ${path}/capricorn.svg -h $size -w $size -f png -o ${path}/${size}x${size}/apps/capricorn.png
done
