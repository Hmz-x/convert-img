# convert-img.sh (WOW!!!)
## Convert images according to flags you choose or auto generate new convertions using the randomize option (FANTASTIC!!)

```
usage: convert-img.sh
	
example: convert-img.sh -i in.jpeg -r -o out.jpeg
example: convert-img.sh --input in.jpeg --mvgn --frame blue red # chain filters back to back!
example: convert-img.sh --input in.jpeg --contrast 0 75 0.8 --swap 20 purple blue
	
HELP/VERSION OPTIONS
	-h|--help
	-v|--version
	
MAIN OPTIONS
	-i|--input INPUT
	-o|--output OUTPUT
	-r|--random

FILTER OPTIONS
	--swap FUZZ_LVL COLOR_SEARCH COLOR_REPLACE | --swap 20 purple black
	--frame COLOR1 COLOR2 | --frame blue black
	--contrast BLACK_POINT_LVL WHITE_POINT_LVL GAMMA_ADJ_VAL | --contrast 0 75 0.5
	--mvgn		(mirror vertically gravity north)	
	--mvgs		(mirror vertically gravity south)	
	--mhge		(mirror horizontally gravity east)	
	--mhgw		(mirror horizontally gravity west)

convert-img.sh 1.0
Licensed under GNU GPLv3
Written by Hamza Kerem Mumcu
```
