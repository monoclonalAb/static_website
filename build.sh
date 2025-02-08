#!/bin/bash

# run this from project root directory to build the website
dir=src # $dir = `.\src` folder
dest=public # $dest = `.\public` folder

# create a directory at $dest, 
# -p = means if any of the parent directories does not exist, then `mkdir` will create them without raising an error
mkdir -p $dest

# copy (-R = recursively) all the files from $dir 
cp -R $dir/* $dest
# remove (-rf = forcefully and recursively) these folders
rm -rf $dest/blog
rm -rf $dest/parts
rm -rf $dest/leetcode

# build thoughts
$dir/blog/build.sh

# build leetcode
$dir/leetcode/build.sh

# replace <!-- NAV --> with src/parts/nav.html
nav=$dir/parts/nav.html # nav.html file
# converts all double quotes (") to single quotes (')
# & remove all new lines to create a temp file ($nav.tmp)
cat $nav | tr '"' "\\\"" | tr -d '\n' > $nav.tmp.html
# sed = stream editor, -i = in-place
# s/ indicates a substitution operation
# e.g. s/pattern/replacement/flags
# pattern = \/
# replacement = \\\/
# flags = -g (global)
sed -i 's/\//\\\//g' $nav.tmp.html
# for every file
for file in $(find $dest -name "*.html"); do
    sed -i "s/<!-- NAV -->/$(cat $nav.tmp.html)/g" $file
done
rm $nav.tmp.html

