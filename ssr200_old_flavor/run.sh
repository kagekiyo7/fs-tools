#!/bin/bash
set -e

sh_dir="$(dirname "$(readlink -f "$0")")"
working_dir="$(dirname "$(readlink -f "$1")")"
filename=$(basename "$1" | sed 's/\.[^.]*$//')
outputdir="${filename}_outout"

cd "$working_dir"
echo "Started remapping the NAND."
python3 "$sh_dir/convert_old_ssr200.py" "$1" "${filename}.oob" "${filename}_remapped.bin"
echo "Success!: ${filename}_remapped.bin"
echo

echo "Started carving FATs. (MSDOS5.0)"
python3 "$sh_dir/carve_msdos50_fat.py" "${filename}_remapped.bin" "$outputdir"
echo

echo "Started extracting FATs."
for fat in "$outputdir"/*.bin; do
    [ -e "$fat" ] || continue
    echo "Processing: $fat"
    tsk_recover -f fat16 -a "$fat" "${fat}_output"
    tsk_recover -f fat16 "$fat" "${fat}_output"
done
echo

echo "Processing completed!"
echo "output => $working_dir/$outputdir"