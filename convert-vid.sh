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
	ffmpeg -i "$v_ch" -vf "format=yuv420p" -color_range 2 -r $fps "$tmp_dir/frame_%d.png"
}

# convert-img each frame
convert_frm()
{
	# Get number of frames in tmp_dir
	frame_num="$(ls "$tmp_dir" | wc -w)"

	# Apply a new (random) fx every N frame
	# Until the next N count is reached, apply the same fx to the following frames
	new_fx_every_n_frame=4 

	count=1
	while ((count <= frame_num)); do
		# Generate new edit
		fname="$tmp_dir/frame_${count}.png" # file name
		./convert-img.sh -i "$fname" -r -o "$fname"

		# Declare fx array, read string of fx from log, assign each field read to new index
		fx_arr=()
		read -r fx_str < "$con_img_log"
		read -ra fx_arr <<< "$fx_str"
		
		# Apply previously created edit to the next $new_fx_every_n_frame frames
		for i in $(seq 1 $new_fx_every_n_frame); do
			fname="$tmp_dir/frame_$((count + i)).png" # file name
			(((count + i) <= frame_num)) && \
				./convert-img.sh -i "$fname" ${fx_arr[@]} -o "$fname"
		done

		count=$((count + new_fx_every_n_frame))
	done
}

# join frames into video
join_frames()
{
	#ffmpeg -framerate $fps -i ./frame_%04d.jpeg -c:v libvpx-vp9 -r $fps -pix_fmt yuv420p output_video_from_frames.mp4
	vid_out="output_video_from_frames.webm"
	ffmpeg -framerate $fps -i "$tmp_dir/frame_%d.png" -c:v libvpx-vp9 -crf 30 -b:v 0 "$vid_out"
}

# Join together video and audio
join_audio_n_video()
{
	ffmpeg -i "$vid_out" -i "$a_ch" -c:v copy -c:a copy output_combined.webm
}

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
con_img_log="/var/log/convert-img/convert-img.log"

parse_opts "$@"

# Get frame rate
get_fps

# Split video into frames
split_vid

# Convert frame
convert_frm

# join frames into video
join_frames

# join together video and audio
join_audio_n_video

#rm -r "
