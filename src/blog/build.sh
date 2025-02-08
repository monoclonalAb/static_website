#!/bin/bash
echo "BUILDING: blog.html"

# magic variables (run from the main directory)
dir=src/blog
dest=public/blog

mkdir -p $dest

# temporary file stores the titles and dates
touch $dir/titles_dates.tmp.html

# get YAML front-matter and convert it to bash variables
# the genius behind converting YAML front-matter to bash variables
# https://www.reddit.com/r/pandoc/comments/f6oxm5/convert_yaml_frontmatter_to_bash_variables/
# Author: https://github.com/cr0sh
# his blog: https://blog.cro.sh/

for subdir in $(find $dir -type d -not -path "$dir"); do
  # basename extracts the name of the directory/file at the end of the path
  dir_name=$(basename $subdir)
  # '#' removes a prefix from a string
  # '*_' matches everything up to and including the first underscore
  file="$subdir/${dir_name#*_}.md"

  # load frontmatter
  pandoc -s $file -o $file.tmp.html --template=$dir/frontmatter.bash --mathml
  source $file.tmp.html
  echo "$doc_date;$doc_title;$file" >> $dir/titles_dates.tmp.html

  # compile file
  pretty_date=$(echo $doc_date | xargs date +'%B %d, %Y' -d)
  output=$(basename ${file%.md}.html)
  pandoc -s $file -o $dest/$output --template=$dir/article-template.html --mathml
  sed -i "s/<!-- TIME -->/$pretty_date/" $dest/$output

  # clear temporary file
  rm -rf $file.tmp.html
done

# sort posts by date
sort -r $dir/titles_dates.tmp.html > $dir/sorted.tmp.html

# to keep track of sub-headings
previous_date="2000-01-01"

# for alternating background-colours:
bit=0

# constant strings
pattern="<!-- CONTENT -->"
closing_tag="<\\/div>$pattern"
table="<div class=\"table\">$pattern"

# initialize the table
sed -i "s/$pattern/$table/g" $dest/../blog.html

# generate blog index page
echo "GENERATING: blog posts"
while IFS= read line; do
  doc_date=$(echo $line | cut -d ';' -f 1)
  doc_title=$(echo $line | cut -d ';' -f 2)
  # in the format Month date, Year e.g. January 09, 2025
  reformatted_doc_date=$(echo $doc_date | xargs date +'%B %d, %Y' -d)
  doc_file=$(echo $line | cut -d ';' -f 3)
  doc_link=${doc_file%.md}.html
  echo "$doc_date: $doc_title"

  href="<a href=\"blog\\/$(basename $doc_link)\">$doc_title<span>.<\\/span><\\/a>"
  if [[ $bit == 0 ]]; then
    class="row sidebar"
  else
    class="row dark"
  fi
  replace="<div class=\"$class\">$href <time>$reformatted_doc_date<\\/time><\\/div>$pattern"
  sed -i "s/$pattern/$replace/g" $dest/../blog.html
  bit=$(($bit ^ 1))
done < $dir/sorted.tmp.html
sed -i "s/$pattern/$closing_tag/g" $dest/../blog.html

# clear all temporary files
rm -rf $dir/*.tmp.html
