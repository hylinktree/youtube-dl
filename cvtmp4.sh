#!/bin/bash

FFMPEG=ffmpeg

do_detect() {
		echo detect \"$1\"
	$FFMPEG -i "$1" -filter:a volumedetect -f null /dev/null
}

if [[ $# == 0 ]]; then
        echo $0 [--mingw] [--mp3-to-m4a] [--m4a] duration-in-minutes name.[mp4\|m4a\|mp3] ...
        exit
fi

if [[ $1 == --mingw ]]; then
	FFMPEG=/c/var/ffmpeg/bin/ffmpeg.exe
	shift
fi

if [[ $1 == --detect ]]; then
	shift
	for((;$#>0;));do
		do_detect "$1"
		shift
	done
	exit
fi

if [[ $1 == --mp3-to-m4a ]]; then
	shift
	for ((;$#>0;)); do
		fname=$(basename -- "$1")
		ffmpeg -i "$1" -c:a aac "${fname%.*}.m4a"
		shift
	done
	exit
fi

TGTTYPE=mp3
if [[ $1 == --m4a ]] ; then
	shift
	TGTTYPE=m4a
fi

do_work()
{
	# $1, the name to treat
	filename=$(basename -- "$1")
	ext="${filename##*.}"
	bname="${filename%.*}"

	odir="./out/$bname"
	mkdir -p "$odir"

	if [[ $ext == m4a ]]; then
		$FFMPEG -i "$bname".m4a -acodec libmp3lame -aq 2 "$bname".mp3
	elif [[ $ext == mp4 ]]; then
		$FFMPEG -i "$bname".mp4 "$bname".mp3
	elif [[ $ext == webm ]]; then
		$FFMPEG -i "$bname".webm "$bname".mp3
	fi
	
	if [[ $dur == 0 ]]; then
		return
	fi

	if [[ $TGTTYPE == mp3 ]]; then
		$FFMPEG -i "$bname".mp3 -f segment -segment_time $dur -c copy "${odir}/${bname}_%03d.mp3"
	else
		$FFMPEG -i "$bname".mp3 -f segment -segment_time $dur -c:a aac "${odir}/${bname}_%03d.m4a"
	fi

}

dur=$(($1*60))
shift
echo Segment slice is $dur

for((;$#>0;)); do
	do_work "$1"
	shift
done
exit

if [[ $# < 2 ]]; then
	exit
fi

filename=$(basename -- "$1")
ext="${filename##*.}"
bname="${filename%.*}"

odir="./out/$bname"
mkdir -p "$odir"

if [[ $ext == m4a ]]; then
	ffmpeg -i "$bname".m4a -acodec libmp3lame -aq 2 "$bname".mp3
elif [[ $ext == mp4 ]]; then
	ffmpeg -i "$bname".mp4 "$bname".mp3
fi

if [[ $dur == 0 ]]; then
	exit
fi

if [[ $TGTTYPE == mp3 ]]; then
	ffmpeg -i "$bname".mp3 -f segment -segment_time $dur -c copy "${odir}/${bname}_%03d.mp3"
else
	ffmpeg -i "$bname".mp3 -f segment -segment_time $dur -c:a aac "${odir}/${bname}_%03d.m4a"
fi


# /c/var/ffmpeg/bin/ffmpeg.exe -i 棉花帝国.mp3 -c copy -f segment -segment_times 10,30,60,100 yy_%03d.mp3
