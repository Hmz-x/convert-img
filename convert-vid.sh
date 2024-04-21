#!/bin/bash

# Program Data
PROGRAM="convert-vid.sh"
LICENSE="GNU GPLv3"
VERSION="1.0"
AUTHOR="Hamza Kerem Mumcu"
USAGE="Usage: $PROGRAM
	
example: $PROGRAM 
	
HELP/VERSION OPTIONS
	-h|--help
	-v|--version
"	

err(){
	printf "%s. Exitting.\n" "$1" >&2
	exit 1
}

show_help(){
	# Print program usage.
	printf "%s\n" "$USAGE"	
	exit 0
}

show_version(){
	# Print program version info.
	printf "%s\n" "$PROGRAM $VERSION"
	printf "Licensed under %s\n" "$LICENSE"
	printf "Written by %s\n" "$AUTHOR"
	exit 0
}

#audio_format="aac"
#video_format="mp4"
#v_ch="video_channel.${video_format}" # video channel
#a_ch="audio_channel.${audio_format}" # audio channel
#v_ch="$1"
#a_ch="$2"

# Split audio and video
# Split audio
#ffmpeg -i "$input" -vn -acodec copy "$a_ch"

## Split video
#ffmpeg -i "$input" -an -vcodec copy "$v_ch"

get_fps()
{
	fps="$(ffprobe "$v_ch" 2>&1 | grep -oP '(\d+\.?\d*) fps' | cut -d ' ' -f 1)"
	partial_fps=$(($(echo "$fps" | awk '{print int($1+0.5)}') / 4))
	fps="$partial_fps"
}

# Split video into frames
split_vid()
{
	#ffmpeg -i "$v_ch" -vf "fps=${fps}" ./frame_%04d.jpeg
	ffmpeg -i "$v_ch" -vf "format=yuv420p" -color_range 2 -r $fps "$tmp_dir/frame_%04d.png"
}

# convert-img each frame
convert_frm()
{
	for frame in frame_*.png; do
		./convert-img.sh -i "$tmp_dir/$frame" --contrast 10 70 0.8 -o "$tmp_dir/$frame"
	done
}

# join frames into video
join_frames()
{
	#ffmpeg -framerate $fps -i ./frame_%04d.jpeg -c:v libvpx-vp9 -r $fps -pix_fmt yuv420p output_video_from_frames.mp4
	ffmpeg -framerate $fps -i "$tmp_dir/frame_%04d.png" -c:v libvpx-vp9 -crf 30 -b:v 0 output_video_from_frames.webm
}

# Join together video and audio

parse_opts(){
	# Parse and evaluate each option one by one 
	while [ "$#" -gt 0 ]; do
		case "$1" in
			#-h|--help) show_help;;
		    #-v|--version) show_version;;
			-a|--audio) a_ch="$2"; shift;;	
			-v|--video) v_ch="$2"; shift;;	
			-i|--input) input="$2"; shift;;	
			--) break;;
			*) err "Unknown option. Please see '--help'";;
		esac
		shift
	done
	
	echo "$input"
}

tmp_dir="$(mktemp -d)"
fps="4"

parse_opts "$@"

# Get frame rate
get_fps

# Split video into frames
split_vid

# join frames into video
join_frames

#rm -r "
