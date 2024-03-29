#!/bin/bash

# TO IMPLEMENT:
# 0) input string validation for user input
# 1) transparent "item" images to be insterted on the main input image,
# implemented with features such as slight rotation, color enchacement, easy duplication placement not to mention resized
# 2) Random functionality implementation: setting defaults for number of fx, etc.
# 2) Output to be automatically sent to the server directory and the website to display output image. The output
# image to be then downloadable after clicking on it.
# Implement special start shape and star formations: make em stack side by side and top and bottom
# Client to send image via signal ? and for automatic downloading and running randomization and sending to server

# Program Data
PROGRAM="$(basename "$0")"
LICENSE="GNU GPLv3"
VERSION="1.0"
AUTHOR="Hamza Kerem Mumcu"
USAGE="Usage: $PROGRAM"

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
	output="${fx_name}_${input}"

	convert "$input" -gravity South -chop 0x50% -flip -write mpr:bottom +delete \
		"$input" -gravity South -chop 0x50% -write mpr:top +delete \
		-append mpr:top mpr:bottom "$output"

	echo "$output"
}

mirror_vertically_gravity_north()
{
	fx_name="mvgn"
	input="$1"
	output="${fx_name}_${input}"
	#[ -f "$input" ] && echo check && file "$input"

	convert "$input" -gravity North -chop 0x50% -flip -write mpr:top +delete \
		"$input" -gravity North -chop 0x50% -write mpr:bottom +delete \
		-append mpr:top mpr:bottom "$output"

	echo "$output"
}

mirror_horizontally_gravity_west()
{
	fx_name="mhgw"
	input="$1"
	output="${fx_name}_${input}"

	convert "$input" -gravity West -chop 50%x0 -flop -write mpr:right +delete \
		"$input" -gravity West -chop 50%x0 -write mpr:left +delete \
		+append mpr:left mpr:right "$output"

	echo "$output"
}

mirror_horizontally_gravity_east()
{
	fx_name="mhge"
	input="$1"
	output="${fx_name}_${input}"

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

	fx_name="swp${fuzz_lvl}%${color_search}%${color_replace}"
	input="$1"
	output="${fx_name}_${input}"

	convert "$input" -fuzz $fuzz_lvl% -fill "$color_replace" -opaque "$color_search" -flatten "$output"
	echo "$output"
}

resize_item_img()
{
	input="$1"
	#convert "$input" 
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
	rand_color_percent=$(get_rand_num 100)
	#echo "rand_color_percent: $rand_color_percent"

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
	rand_fuzz_percent=$(get_rand_num 100)
	#echo "rand_fuzz_percent: $rand_fuzz_percent"

	if ((5 >= rand_fuzz_percent && rand_fuzz_percent >= 1)); then
		fuzz_lvl=5
	elif ((15 >= rand_fuzz_percent && rand_fuzz_percent >= 6)); then
		fuzz_lvl=10
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
	random_search_percent=$(get_rand_num 100)
	#echo "random_search_percent: $random_search_percent"

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
}

randomize_all()
{
	# First two argument is input flag and input
	random_args+=("--input" "$1")

	# 35% chance swap color
	swap_color_chance=100
	swap_color_percent=$(get_rand_num 100)
	((swap_color_percent <= swap_color_chance)) && randomize_swap_color

	# 35% chance mirror img
	mirror_img_chance=100
	mirror_img_percent=$(get_rand_num 100)
	((mirror_img_percent <= mirror_img_chance)) && randomize_mirror_img

	parse_opts "${random_args[@]}"
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
			--swap) input="$(swap_colors "$input" "$2" "$3" "$4")";
					# shift forward to next CLI args 3 times
					for i in $(seq 1 3); do
						shift
					done;;
			-r|--random) input="$(randomize_all "$input")";;
			 --) break;;
			  *) err "Unknown option. Please see '--help'";;
		esac
		shift
	done
	
	echo "$input"
}

#random_args=()
file_output=""
parse_opts "$@"
#echo "input $input"
#echo "output $file_output"
#[ -n "$file_output" ] && mv "$input" "$file_output"

