#! /bin/bash
#  unflat - Hierarchical Arrangement Script for the danbooru data folder
#  Version 1
#  (hopefully the only one OwO)
#
#  Author: Glassed Silver

#  Welcoming the user and disclaimer
printf "\nunflat - Hierarchical Arrangement Script for the danbooru data folder 
Version 1 
Author: Glassed Silver 

This is a shell script and the methodical alternative to the fix script 77, 
only that this script doesn't intend to create any symlinks, 
but rather move all files in the root data folder and its sub-
directories crop, sample and preview to the non-flat, hierarchical 
file structure, that is now the only way danbooru stores files 
going forward. 

  IMPORTANT: MAKE SURE YOU BACKED UP YOUR 
  /home/danbooru/danbooru/public/data folder 
  and that you run this script as the danbooru user! 
  I take no responsibility for anything that gets borked 
  or breaks from this, so be cautious! Run this INSTEAD of 077_symlink_subdirectories.rb!\n\n\n"

#  Prompt to continue
read -p "Press enter to continue (ctrl+c to cancel)"
printf "\nPreparing... \n"

cd ~/danbooru/public/data/
mkdir ../data-processing
mv * ../data-processing/ && mkdir original
mv ../data-processing/crop crop/
mv ../data-processing/sample sample/
mv ../data-processing/preview preview/
cd ../data-processing/

printf "Beginning now \n
Stage 1 - ~/danbooru/public/data/ (originals are in original/ going forward) \n"

for f in *; do if [ ! -d "$f" ]; then d="${f:0:2}"; mkdir -p "$d"; mv -t "$d" -- "$f"; fi; done
for dir in ./*; do (cd "$dir" && for f in *; do if [ ! -d "$f" ]; then d="${f:2:2}"; mkdir -p "$d"; mv -t "$d" -- "$f"; fi; done); done
cd ..
mv data-processing/* data/original/ && rmdir data-processing
cd data/

printf "Stage 2 - ~/danbooru/public/data/crop \n"

cd crop/
for f in *; do if [ ! -d "$f" ]; then d="${f:0:2}"; mkdir -p "$d"; mv -t "$d" -- "$f"; fi; done
for dir in ./*; do (cd "$dir" && for f in *; do if [ ! -d "$f" ]; then d="${f:2:2}"; mkdir -p "$d"; mv -t "$d" -- "$f"; fi; done); done
cd ..

printf "Stage 3 - ~/danbooru/public/data/preview \n"

cd preview/
for f in *; do if [ ! -d "$f" ]; then d="${f:0:2}"; mkdir -p "$d"; mv -t "$d" -- "$f"; fi; done
for dir in ./*; do (cd "$dir" && for f in *; do if [ ! -d "$f" ]; then d="${f:2:2}"; mkdir -p "$d"; mv -t "$d" -- "$f"; fi; done); done
cd ..

printf "Stage 4 - ~/danbooru/public/data/sample \n\n"

cd sample/
for f in *; do if [ ! -d "$f" ]; then d="${f:7:2}"; mkdir -p "$d"; mv -t "$d" -- "$f"; fi; done
for dir in ./*; do (cd "$dir" && for f in *; do if [ ! -d "$f" ]; then d="${f:9:2}"; mkdir -p "$d"; mv -t "$d" -- "$f"; fi; done); done
cd ..

printf "DONE \nEnjoy your day! :) \n\n"
