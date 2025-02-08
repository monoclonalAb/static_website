#!/bin/bash

# magic variables (run from the main directory)
dir=src/leetcode
dest=public/leetcode

mkdir -p $dest

# temporary file stores the titles and dates
touch $dir/question_data.tmp.html

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
      pandoc -s $file -o $file.tmp.html --template=$dir/frontmatter.bash --mathml
      source $file.tmp.html
      echo "$formatted_date;$daily_title;$daily_question_id;$daily_question_link;$daily_difficulty" >> $dir/question_data.tmp.html
      
      # compile file
      output=$(basename ${file%.md}.html)
      pandoc -s $file -o $dest/$output --template=$dir/daily-template.html --mathml
      sed -i "s/<!-- TIME -->/$formatted_date/" $dest/$output

      # clear temporary file
      rm -rf $file.tmp.html
    done
  done
done


# sort posts by date
sort -r $dir/question_data.tmp.html > $dir/sorted.tmp.html

# to keep track of sub-headings
previous_date="2000-01-01"

# for alternating background-colours:
bit=0

# constant strings
pattern="<!-- CONTENT -->"
closing_tag="<\\/div>$pattern"

# generate index page
# '-d' (delimeter)
# '-f' (field numbex, starting index = 1)
while IFS= read line; do
  daily_date=$(echo $line | cut -d ';' -f 1 )
  # all the spaces in `daily_title` are equal to `-`
  daily_title=$(echo $line | cut -d ';' -f 2) 
  # `formatted_daily_title` aims to replace all `-` with ` `
  formatted_daily_title=$(echo $daily_title | sed 's/-/ /g')
  daily_question_id=$(echo $line | cut -d ';' -f 3)
  daily_question_link=$(echo $line | cut -d ';' -f 4)
  daily_difficulty=$(echo $line | cut -d ';' -f 5)

  # check what previous month is; if different, create new heading and div
  if [[ $(echo "$previous_date" | cut -d '-' -f 1-2) != $(echo $daily_date | cut -d '-' -f 1-2) ]]; then
    # adding closing tags to each table (for each month)
    if [[  $previous_date != "2000-01-01"  ]]; then
        bit=0
        sed -i "s/$pattern/$closing_tag/g" $dest/../leetcode.html
    fi
    
    # update the previous date
    previous_date=$daily_date

    month_year=$(echo $daily_date | xargs date +'%B %Y' -d)
    header="<br><h2>$month_year<span>:<\\/span><\\/h2>"
    table="<div class=\"table\">$pattern"
    sed -i "s/$pattern/$header$table/g" $dest/../leetcode.html
  fi


  href="<a href=\"leetcode\\/${daily_date}.html\"><b>$daily_question_id<\\/b><span>.<\\/span> $formatted_daily_title<\\/a>"
  if [[ $bit == 0 ]]; then
    class="row"
  else
    class="row dark"
  fi
  replace="<div class=\"$class $daily_difficulty\">$href <time>$daily_date<\\/time> <difficulty class=\"$daily_difficulty\">$daily_difficulty<\\/difficulty><\\/div>$pattern"
  sed -i "s/$pattern/$replace/g" $dest/../leetcode.html
  bit=$(($bit ^ 1))
done < $dir/sorted.tmp.html
sed -i "s/$pattern/$closing_tag/g" $dest/../leetcode.html

# clear all temporary files
rm -rf $dir/*.tmp.html
