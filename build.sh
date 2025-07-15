#!/bin/bash

# run this from project root directory to build the website
dir=src # $dir = `.\src` folder
dest=public # $dest = `.\public` folder

if [ -z "$1" ]; then
  PAGES="ALL"
else
  if [ "$1" = "BLOG" ]; then
    PAGES="BLOG"
  elif [ "$1" = "LEETCODE" ]; then
    PAGES="LEETCODE"
  else
    PAGES="ALL"
  fi
fi


# create a directory at $dest, 
# -p = means if any of the parent directories does not exist, then `mkdir` will create them without raising an error
mkdir -p $dest

# copy (-R = recursively) all the files from $dir 
cp -R $dir/* $dest
# remove (-rf = forcefully and recursively) these folders
rm -rf $dest/parts

if [[ $PAGES = "BLOG" || $PAGES = "ALL" ]]; then
  # build thoughts
  rm -rf $dest/blog
  $dir/blog/build.sh
fi

if [[ $PAGES = "LEETCODE" || $PAGES = "ALL" ]]; then
  # build leetcode
  rm -rf $dest/leetcode
  $dir/leetcode/build.sh
fi

# build navbar
$dir/parts/navbar/generateNavbar.sh
