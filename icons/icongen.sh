#!/bin/bash

sizes_mini=(16 22 24)
sizes=(32 48 64 128 256)

for size in ${sizes_mini[@]}
do
	rsvg-convert capricorn_mini.svg -h $size -w $size -f png -o ${size}x${size}/capricorn.png
done

for size in ${sizes[@]}
do
	rsvg-convert capricorn.svg -h $size -w $size -f png -o ${size}x${size}/capricorn.png
done
