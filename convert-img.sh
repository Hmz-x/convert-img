#!/bin/bash

# TODO
# 0) Working on "pretty effect"
# 1) transparent "item" images to be insterted on the main input image,
# implemented with features such as slight rotation, color enchacement, easy duplication placement not to mention resized
# Implement special start shape and star formations: make em stack side by side and top and bottom
# Client to send image via signal ? and for automatic downloading and running randomization and sending to server

# Program Data
PROGRAM="convert-img.sh"
LICENSE="GNU GPLv3"
VERSION="1.2"
AUTHOR="Hamza Kerem Mumcu"
USAGE="Usage: $PROGRAM
	
example: $PROGRAM -i in.jpeg -r -o out.jpeg
example: $PROGRAM --input in.jpeg --mvgn --frame blue red # chain filters back to back!
example: $PROGRAM -l mylog -i in.jpeg --contrast 0 75 0.8 --swap 20 purple blue
	
HELP/VERSION OPTIONS
	-h|--help
	-v|--version
	
MAIN OPTIONS
	-i|--input INPUT
	-o|--output OUTPUT
	-r|--random
	-l|--log LOG_FILE

FILTER OPTIONS
	--swap FUZZ_LVL COLOR_SEARCH COLOR_REPLACE | --swap 20 purple black
	--frame COLOR1 COLOR2 | --frame blue black
	--contrast BLACK_POINT_LVL WHITE_POINT_LVL GAMMA_ADJ_VAL | --contrast 0 75 0.5
	--mvgn		(mirror vertically gravity north)	
	--mvgs		(mirror vertically gravity south)	
	--mhge		(mirror horizontally gravity east)	
	--mhgw		(mirror horizontally gravity west)"	

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

mirror_vertically_gravity_south()
{
	fx_name="mvgs"
	input="$1"
	output="$(dirname "$input")/${fx_name}_$(basename "$input")"

	convert "$input" -gravity South -chop 0x50% -flip -write mpr:bottom +delete \
		"$input" -gravity South -chop 0x50% -write mpr:top +delete \
		-append mpr:top mpr:bottom "$output"

	echo "$output"
}

mirror_vertically_gravity_north()
{
	fx_name="mvgn"
	input="$1"
	output="$(dirname "$input")/${fx_name}_$(basename "$input")"

	convert "$input" -gravity North -chop 0x50% -flip -write mpr:top +delete \
		"$input" -gravity North -chop 0x50% -write mpr:bottom +delete \
		-append mpr:top mpr:bottom "$output"

	echo "$output"
}

mirror_horizontally_gravity_west()
{
	fx_name="mhgw"
	input="$1"
	output="$(dirname "$input")/${fx_name}_$(basename "$input")"

	convert "$input" -gravity West -chop 50%x0 -flop -write mpr:right +delete \
		"$input" -gravity West -chop 50%x0 -write mpr:left +delete \
		+append mpr:left mpr:right "$output"

	echo "$output"
}

mirror_horizontally_gravity_east()
{
	fx_name="mhge"
	input="$1"
	output="$(dirname "$input")/${fx_name}_$(basename "$input")"

	convert "$input" -gravity East -chop 50%x0 -flop -write mpr:left +delete \
		"$input" -gravity East -chop 50%x0 -write mpr:right +delete \
		+append mpr:left mpr:right "$output"

	echo "$output"
}

swap_colors()
{
	fuzz_lvl="$2"
	color_search="$3"
	color_replace="$4"

	fx_name="swp${fuzz_lvl}-${color_search}-${color_replace}"
	input="$1"
	output="$(dirname "$input")/${fx_name}_$(basename "$input")"

	convert "$input" -debug None -fuzz $fuzz_lvl% -fill "$color_replace" -opaque "$color_search" -flatten "${output}"
	echo "$output"
}

add_frame()
{
	fx_name="frm"
	input="$1"
	output="$(dirname "$input")/${fx_name}_$(basename "$input")"
	tmp_file="$(mktemp)"

	convert "$input" \( +clone  -background "$2"  -shadow 60x20-10+10 \) \
		+swap -background none -layers merge +repage "$tmp_file" && \
	convert "$tmp_file" \( +clone  -background "$3"  -shadow 60x20+10+10 \) \
		+swap -background none -layers merge +repage "$output"
	
	rm "$tmp_file"	
	echo "$output"
}

add_contrast()
{
	fx_name="cntrst"
	input="$1"
	output="$(dirname "$input")/${fx_name}_$(basename "$input")"

	convert "$input" -level $2%,$3%,"$4" "$output"

	echo "$output"
}

get_rand_num()
{
	limit=$1
	random_num=$((1 + $RANDOM % $limit))
	echo $random_num
}

get_rand_color()
{
	# 1-20%: purple, 21-40%: pink, 41-55%: orange, 56-70% yellow, 71-75%: blue, 76-80%: green, 81-85%: red
	# 86-90%: brown, 91-95: black, 96-100: white
	rand_color_percent=$(get_rand_num $random_color_limit)

	if ((20 >= rand_color_percent && rand_color_percent >= 1)); then
		random_color="purple"	
	elif ((40 >= rand_color_percent && rand_color_percent >= 21)); then
		random_color="pink"	
	elif ((55 >= rand_color_percent && rand_color_percent >= 41)); then
		random_color="orange"	
	elif ((70 >= rand_color_percent && rand_color_percent >= 56)); then
		random_color="yellow"	
	elif ((75 >= rand_color_percent && rand_color_percent >= 71)); then
		random_color="blue"	
	elif ((80 >= rand_color_percent && rand_color_percent >= 76)); then
		random_color="green"	
	elif ((85 >= rand_color_percent && rand_color_percent >= 81)); then
		random_color="red"	
	elif ((90 >= rand_color_percent && rand_color_percent >= 86)); then
		random_color="brown"	
	elif ((95 >= rand_color_percent && rand_color_percent >= 91)); then
		random_color="black"	
	else
		random_color="white"
	fi

	echo "$random_color"
}

randomize_swap_color()
{
	# first determine fuzz level. 
	# 1-5%: 5, 6-15%: 10, 26-35%: 15, 36-55%: 20, 56-75%: 25, 76-85%: 30, 86-95% 35, 96-100%: 40
	rand_fuzz_percent=$(get_rand_num $random_color_limit)
	#echo "rand_fuzz_percent: $rand_fuzz_percent"

	if ((5 >= rand_fuzz_percent && rand_fuzz_percent >= 1)); then
		fuzz_lvl=5
	elif ((15 >= rand_fuzz_percent && rand_fuzz_percent >= 6)); then
		fuzz_lvl=10
	elif ((25 >= rand_fuzz_percent && rand_fuzz_percent >= 16)); then
		fuzz_lvl=13
	elif ((35 >= rand_fuzz_percent && rand_fuzz_percent >= 26)); then
		fuzz_lvl=15
	elif ((55 >= rand_fuzz_percent && rand_fuzz_percent >= 36)); then
		fuzz_lvl=20
	elif ((75 >= rand_fuzz_percent && rand_fuzz_percent >= 56)); then
		fuzz_lvl=25
	elif ((86 >= rand_fuzz_percent && rand_fuzz_percent >= 76)); then
		fuzz_lvl=30
	elif ((95 >= rand_fuzz_percent && rand_fuzz_percent >= 86)); then
		fuzz_lvl=35
	else
		fuzz_lvl=40
	fi

	# secondly determine search color
	# 1-40%: white 70-41%: black 100-71:% any random color
	random_search_percent=$(get_rand_num $random_color_limit)

	if ((40 >= random_search_percent && random_search_percent >= 1)); then
		search_color="white"
	elif ((70 >= random_search_percent && random_search_percent >= 41)); then
		search_color="black"
	else
		search_color="$(get_rand_color)"
	fi

	# finally, determine replace color
	replace_color="$(get_rand_color)"

	random_args+=("--swap" $fuzz_lvl "$search_color" "$replace_color")
}

randomize_mirror_img()
{
	rand_mirror_fx=$(get_rand_num 4)
	case $rand_mirror_fx in 
		1) random_args+=("--mvgs");;
		2) random_args+=("--mvgn");;
		3) random_args+=("--mhge");;
		4) random_args+=("--mhgw");;
	esac
	
	# Add randomization where if --mvgs or --mvgn is used,
	# there is a %50 chance where --mhge or --mhgw is also called
	arr_count=${#random_args[@]}
	if [ "${random_args[$((arr_count - 1))]}" == "--mvgs" ] ||
		[ "${random_args[$((arr_count - 1))]}" == "--mvgn" ]; then

		rand_mirror_fx=$(get_rand_num 4)
		# Only add --mhge/mhgw if not already existent in random_args
		case $rand_mirror_fx in 
			1) :;;
			2) :;;
			3) echo "${random_args[@]}" | grep -q "--mhge" || random_args+=("--mhge");;
			4) echo "${random_args[@]}" | grep -q "--mhgw" || random_args+=("--mhgw");;
		esac
	fi
}

randomize_frame()
{
	random_args+=("--frame")
	
	for i in $(seq 1 2); do
		random_frame_percent=$(get_rand_num 100)
		if ((20 >= random_frame_percent && random_frame_percent >= 1)); then
			frame_color="white"
		elif ((40 >= random_frame_percent && random_frame_percent >= 21)); then
			frame_color="black"
		else
			frame_color="$(get_rand_color)"
		fi
		
		random_args+=("$frame_color")
	done
}

randomize_contrast()
{
	random_args+=("--contrast")

	# First contrast argument (BLACK_PNT_LVL): 0 is non-applied, 25 is pretty
	random_contrast_percent=$(get_rand_num $random_contrast_limit)
	random_args+=("$random_contrast_percent")

	# Second contrast argument (WHITE_PNT_LVL): 100 is non-applied, 75 is pretty
	white_pnt_lvl=$((100 - $(get_rand_num $random_contrast_limit)))
	random_contrast_percent=$white_pnt_lvl
	random_args+=("$white_pnt_lvl")

	random_gamma_percent=$(get_rand_num 100)
	if ((50 >= random_gamma_percent && random_gamma_percent >= 1)); then
		gamma_val="1.0"
	elif ((60 >= random_gamma_percent && random_gamma_percent >= 51)); then
		gamma_val="0.8"
	elif ((70 >= random_gamma_percent && random_gamma_percent >= 61)); then
		gamma_val="1.2"
	elif ((80 >= random_gamma_percent && random_gamma_percent >= 71)); then
		gamma_val="0.6"
	elif ((90 >= random_gamma_percent && random_gamma_percent >= 81)); then
		gamma_val="1.4"
	else
		gamma_val="2.0"
	fi
	
	random_args+=("$gamma_val")
}

randomize_all()
{
	# First two argument is input flag and input
	random_args+=("--input" "$1")

	# Randomly determine min_fx_cnt for every image
	min_fx_cnt=$(get_rand_num 2)

	# Randomize fx until min_fx_cnt is reached
	fx_added_cnt=0
	while ((fx_added_cnt < min_fx_cnt)); do

		# 35% chance add frame
		add_frame_chance=35
		add_frame_percent=$(get_rand_num 100)
		((add_frame_percent <= add_frame_chance)) && randomize_frame && ((fx_added_cnt++))

		# 35% chance swap color
		swap_color_chance=35
		swap_color_percent=$(get_rand_num 100)
		((swap_color_percent <= swap_color_chance)) && randomize_swap_color && ((fx_added_cnt++))

		# 35% chance add contrast
		add_contrast_chance=35
		add_contrast_percent=$(get_rand_num 100)
		((add_contrast_percent <= add_contrast_chance)) && randomize_contrast && ((fx_added_cnt++))

		# 35% chance mirror img
		mirror_img_chance=35
		mirror_img_percent=$(get_rand_num 100)
		((mirror_img_percent <= mirror_img_chance)) && randomize_mirror_img && ((fx_added_cnt++))

	done
	
	[ -w "$log_file" ] && echo "${random_args[@]:2}" > "$log_file"

	parse_opts "${random_args[@]}"
}

check_deps()
{
	[ -z "$(command -v "convert")" ]  && err "convert not found in path"
}

parse_opts(){
	# Parse and evaluate each option one by one 
	while [ "$#" -gt 0 ]; do
		case "$1" in
			-h|--help) show_help;;
		    -v|--version) show_version;;
			-i|--input) input="$2"; shift;;
			-o|--output) file_output="$2"; shift;;
			--mvgs) input="$(mirror_vertically_gravity_south "$input")";;
			--mvgn) input="$(mirror_vertically_gravity_north "$input")";;
			--mhge) input="$(mirror_horizontally_gravity_east "$input")";;
			--mhgw) input="$(mirror_horizontally_gravity_west "$input")";;
			--swap) input="$(swap_colors "$input" "$2" "$3" "$4")"
					# shift forward to next CLI args 3 times
					shift_cnt=3
					for i in $(seq 1 $shift_cnt); do shift; done;;
			--frame) input="$(add_frame "$input" "$2" "$3")"
					shift_cnt=2
					for i in $(seq 1 $shift_cnt); do shift; done;;
			--contrast) input="$(add_contrast "$input" "$2" "$3" "$4")"
					shift_cnt=3
					for i in $(seq 1 $shift_cnt); do shift; done;;
			-r|--random) input="$(randomize_all "$input")";;
			-l|--log) log_file="$2"; shift;;
			 --) break;;
			  *) err "Unknown option: '$1'. Please see '--help'";;
		esac
		shift
	done
	
	echo "$input"
}

# Default minimum amount of times an effect will be applied
min_fx_cnt=1
# Pretty limit for random contrast arguments (anything more than this value might look ugly)
random_contrast_limit=46
# Pretty limit for random color arguments (anything more than this value might look ugly)
random_color_limit=60
file_output=""

# Check dependencies are found on system
check_deps
# Parse CLI args
parse_opts "$@"
[ -n "$file_output" ] && mv "$input" "$file_output"
