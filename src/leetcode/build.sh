#!/bin/bash

# magic variables (run from the main directory)
dir=src/leetcode
dest=public/leetcode

mkdir -p $dest

# temporary file stores the titles and dates
touch $dir/question_data.tmp

# get YAML front-matter and convert it to bash variables
# the genius behind converting YAML front-matter to bash variables
# https://www.reddit.com/r/pandoc/comments/f6oxm5/convert_yaml_frontmatter_to_bash_variables/
# Author: https://github.com/cr0sh
# his blog: https://blog.cro.sh/

for year in $(find $dir -type d -not -path "$dir"); do
  for month in $(find $year -type d -not -path "$year"); do
    for day in $(find $month -type d -not -path "$month"); do
      # basename extracts the name of the directory/file at the end of the path
      formatted_date=$(echo "$day" | cut -d'/' -f3-5 | tr '/' '-')
      file=$day/${formatted_date}.md

      # load frontmatter
      pandoc -s $file -o $file.tmp --template=$dir/frontmatter.bash
      source $file.tmp
      echo "$formatted_date;$daily_title;$daily_question_id;$daily_question_link;$daily_difficulty" >> $dir/question_data.tmp
      
      # compile file
      output=$(basename ${file%.md}.html)
      pandoc -s $file -o $dest/$output --template=$dir/daily-template.html \
             --mathml
      sed -i "s/<!-- TIME -->/$formatted_date/" $dest/$output

      # clear temporary file
      rm -rf $file.tmp
    done
  done
done


# sort posts by date
sort -r $dir/question_data.tmp > $dir/sorted.tmp
sort -r $dir/question_data.tmp > $dest/sorted.tmp

# generate index page
while IFS= read line; do
  echo $line
  daily_date=$(echo $line | cut -d ';' -f1 )
  daily_title=$(echo $line | cut -d ';' -f2)
  daily_question_id=$(echo $line | cut -d ';' -f3)
  daily_question_link=$(echo $line | cut -d ';' -f4)
  daily_difficulty=$(echo $line | cut -d ';' -f5)

  href="<a href='leetcode\\/${daily_date}.html'>$daily_title<\\/a>"
  pattern="<!-- CONTENT -->"
  replace="<li>$href <time>$daily_date<\\/time><\\/li>$pattern"
  sed -i "s/$pattern/$replace/g" $dest/../leetcode.html
done < $dir/sorted.tmp

# clear all temporary files
rm -rf $dir/*.tmp
