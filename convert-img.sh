#!/bin/bash

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
#mirror_horizontally_gravity_west "$1"
