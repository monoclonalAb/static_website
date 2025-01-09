#!/bin/bash

# magic variables (run from the main directory)
dir=src/blog
dest=public/blog

mkdir -p $dest

# temporary file stores the titles and dates
touch $dir/titles_dates.tmp

# get YAML front-matter and convert it to bash variables
# the genius behind converting YAML front-matter to bash variables
# https://www.reddit.com/r/pandoc/comments/f6oxm5/convert_yaml_frontmatter_to_bash_variables/
# Author: https://github.com/cr0sh
# his blog: https://blog.cro.sh/

for subdir in $(find $dir -type d); do
    for file in $(find $subdir/*.md -not -name index.md); do
      # load frontmatter
      pandoc -s $file -o $file.tmp --template=$dir/frontmatter.bash
      source $file.tmp
      echo "$doc_date;$doc_title;$file" >> $dir/titles_dates.tmp

      # compile file
      pretty_date=$(echo $doc_date | xargs date +'%B %d, %Y' -d)
      output=$(basename ${file%.md}.html)
      pandoc -s $file -o $dest/$output --template=$dir/article-template.html \
             --mathml
      sed -i "s/<!-- TIME -->/$pretty_date/" $dest/$output
  done
done

# sort posts by date
sort -r $dir/titles_dates.tmp > $dir/sorted.tmp

# generate index page
pandoc -s $dir/index.md -o $dest/../blog.html \
       --template=$dir/index-template.html
while IFS= read line; do
  doc_title=$(echo $line | cut -d ';' -f2)
  doc_date=$(echo $line | cut -d ';' -f1 | xargs date +'%B %d, %Y' -d)
  doc_file=$(echo $line | cut -d ';' -f3)
  doc_link=${doc_file%.md}.html

  href="<a href='blog\\/$(basename $doc_link)'>$doc_title<\\/a>"
  pattern="<!-- CONTENT -->"
  replace="<li>$href <time>$doc_date<\\/time><\\/li>$pattern"
  sed -i "s/$pattern/$replace/g" $dest/../blog.html
done < $dir/sorted.tmp

# clear all temporary files
rm -rf $dir/*.tmp
