#!/bin/bash

# TODO
# 0) get right video codec for file name and make a_ch and v_ch formats match
# 1) use yt-dlp to get vid if link given..
# -f 'bestvideo[ext=mp4]+bestaudio[ext=m4a]/mp4'
#  on --sec X amount of secnd

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

# Split into audio and video channels
split_into_audio_n_video()
{
	v_ch="$tmp_dir/vid.mp4"
	a_ch="$tmp_dir/audio.avi"

	# get audio channel
	ffmpeg -i "$input" -vn -acodec copy "$a_ch"

	# get video channel
	ffmpeg -i "$input" -an -vcodec copy "$v_ch"
}

ytdl_vid()
{
	#title="$(yt-dlp --get-title "$input")"

	v_ch="$tmp_dir/vid.mp4"
	a_ch="$tmp_dir/audio.m4a"
	yt-dlp -f 'bestvideo[ext=mp4]' "$input" -o "$v_ch"
	yt-dlp -f 'bestaudio[ext=m4a]' "$input" -o "$a_ch"
}

get_fps()
{
	fps="$(ffprobe "$v_ch" 2>&1 | grep -oP '(\d+\.?\d*) fps' | cut -d ' ' -f 1)"
	partial_fps=$(($(echo "$fps" | awk '{print int($1+0.5)}') / 1))
	fps="$partial_fps"
}

# Split video into frames
split_vid()
{
	ffmpeg -i "$v_ch" -vf "format=yuv420p" -color_range 2 -r $fps "$tmp_dir/frame_%d.png"
}

# convert-img each frame
convert_frm()
{
	# Get number of frames in tmp_dir
	frame_num="$(ls "$tmp_dir" | wc -w)"

	# Apply a new (random) fx every N frame
	# Until the next N count is reached, apply the same fx to the following frames
	[ -z "$new_fx_every_n_frame" ] && new_fx_every_n_frame=18

	count=1
	while ((count <= frame_num)); do
		# Generate new edit using --random
		fname="$tmp_dir/frame_${count}.png" # file name
		[ -r "$fname" ] && convert-img.sh -l "$con_img_log" -i "$fname" -r -o "$fname"
		echo "~.~.~ $count/$frame_num ~.~.~"

		# Declare fx array, read string of fx from log, assign each field read to new index
		fx_arr=()
		read -r fx_str < "$con_img_log"
		read -ra fx_arr <<< "$fx_str"
		
		# Apply previously created edit (last --random generated flags)
		# to the next $new_fx_every_n_frame frames
		for i in $(seq 1 $new_fx_every_n_frame); do
			fname="$tmp_dir/frame_$((count + i)).png" # file name
			if [ -r "$fname" ]; then
				convert-img.sh -i "$fname" ${fx_arr[@]} -o "$fname"
				echo "~.~.~ $((count + i))/$frame_num ~.~.~"
			else
				break
			fi
		done

		count=$((count + new_fx_every_n_frame))
	done
}

# join frames into video
join_frames()
{
	#ffmpeg -framerate $fps -i ./frame_%04d.jpeg -c:v libvpx-vp9 -r $fps -pix_fmt yuv420p output_video_from_frames.mp4
	vid_out="$tmp_dir/output_video_from_frames.mp4"
	ffmpeg -framerate $fps -i "$tmp_dir/frame_%d.png" -c:v libvpx-vp9 -crf 30 -b:v 0 "$vid_out"
}

# Join together video and audio
join_audio_n_video()
{
	[ -z "$output" ] && output=output_combined.mp4
	ffmpeg -i "$vid_out" -i "$a_ch" -c:v copy -c:a copy "$output"
}

check_deps()
{
	deps=("convert-img.sh" "ffmpeg" "ffprobe" "convert")
	for pkg in "${deps[@]}"; do
		[ -z "$(command -v "$pkg")" ]  && err "$pkg not found in path"
	done
}

parse_opts(){
	# Parse and evaluate each option one by one 
	while [ "$#" -gt 0 ]; do
		case "$1" in
			-h|--help) show_help;;
		    --version) show_version;;
			-s|--split) input="$2"; split_into_audio_n_video; shift;;
			-a|--audio) a_ch="$2"; shift;;	
			-v|--video) v_ch="$2"; shift;;	
			-y|--ytdl) input="$2"; ytdl_vid; shift;;	
			-o|--output) output="$2"; shift;;	
			-n|--num) new_fx_every_n_frame="$2"; shift;;	
			--) break;;
			*) err "Unknown option. Please see '--help'";;
		esac
		shift
	done
	
	echo "$input"
}

# Create temp directory and temp log file
tmp_dir="$(mktemp -d)"
con_img_log="$tmp_dir/convert-img.log"
touch "$con_img_log"

# Check dependencies are found on system
check_deps

# Parse CLI args
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

[ $? -eq 0 ] && rm -r "$tmp_dir"
