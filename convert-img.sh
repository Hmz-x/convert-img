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


mirror_vertically_gravity_south()
{
	input="$1"
	convert "$input" -gravity South -chop 0x50% -flip -write mpr:bottom +delete \
		"$input" -gravity South -chop 0x50% -write mpr:top +delete \
		-append mpr:top mpr:bottom "$input"
}

mirror_vertically_gravity_north()
{
	input="$1"
	convert "$input" -gravity North -chop 0x50% -flip -write mpr:top +delete \
		"$input" -gravity North -chop 0x50% -write mpr:bottom +delete \
		-append mpr:top mpr:bottom "$input"
}

mirror_horizontally_gravity_west()
{
	input="$1"
	convert "$input" -gravity West -chop 50%x0 -flop -write mpr:right +delete \
		"$input" -gravity West -chop 50%x0 -write mpr:left +delete \
		+append mpr:left mpr:right "out-$input"
}

mirror_horizontally_gravity_east()
{
	input="$1"
	convert "$input" -gravity East -chop 50%x0 -flop -write mpr:left +delete \
		"$input" -gravity East -chop 50%x0 -write mpr:right +delete \
		+append mpr:left mpr:right "out-$input"
}

resize_item_img()
{
	input="$1"
	#convert "$input" 
}


#mirror_vertically "$1"
#mirror_vertically_gravity_north "$1"
mirror_horizontally_gravity_west "$1"
