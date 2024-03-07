#!/bin/bash

mirror_vertically()
{
	input="$1"
	convert "$input" -gravity South -chop 0x50% -flip -write mpr:bottom +delete \
		"$input" -gravity South -chop 0x50% -write mpr:top +delete \
		-append mpr:top mpr:bottom "$input"
}

mirror_vertically_gravity_north()
{
	input="$1"
	convert "$input" -gravity South -chop 0x50% -flip -write mpr:bottom +delete \
		"$input" -gravity North -chop 0x50% -write mpr:top +delete \
		-append mpr:top mpr:bottom "$input"
}


mirror_vertically "$1"
#mirror_vertically_gravity_north "$1"
