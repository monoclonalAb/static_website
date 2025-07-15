#!/bin/bash

echo "BUILDING: leetcode.html"

# magic variables (run from the main directory)
dir=src/leetcode
dest=public/leetcode

if [ -z "$1" ]; then
  rm -rf "$dest"
  mkdir -p "$dest"

  # arrays to store question data (avoid temporary files)
  declare -a question_dates
  declare -a question_titles
  declare -a question_ids
  declare -a question_links
  declare -a question_difficulties

  echo "Processing LeetCode questions..."
  
  # use find with proper sorting and process files efficiently
  while IFS= read -r -d '' file; do
    echo "$file"
    
    # extract formatted date from filename
    formatted_date="${file##*/}"
    formatted_date="${formatted_date%.md}"
    
    # load frontmatter (removing --mathml gives a bunch of "errors")
    pandoc -s "$file" -o "$file.tmp.html" --template="$dir/frontmatter.bash" --mathml
    source "$file.tmp.html"
    
    # store in arrays
    question_dates+=("$formatted_date")
    question_titles+=("$daily_title")
    question_ids+=("$daily_question_id")
    question_links+=("$daily_question_link")
    question_difficulties+=("$daily_difficulty")
    
    # compile file
    output="${file##*/}"
    output="${output%.md}.html"
    pandoc -s "$file" -o "$dest/$output" \
        --template="$dir/daily-template.html" \
        --mathml --toc --toc-depth=2 \
        --variable="formatted_date:$formatted_date"
    
    # clean up
    rm -f "$file.tmp.html"
  done < <(find "$dir" -name "*.md" -type f -print0 | sort -z)

  # create combined data for sorting (in memory)
  combined_data=""
  for i in "${!question_dates[@]}"; do
    combined_data+="${question_dates[$i]};${question_titles[$i]};${question_ids[$i]};${question_links[$i]};${question_difficulties[$i]}"$'\n'
  done

  # sort questions by date (reverse chronological)
  sorted_data=$(echo "$combined_data" | sort -r)

  # pre-build all HTML content to minimize sed calls
  echo "GENERATING: LeetCode index page"
  
  previous_month=""
  bit=0
  all_content=""
  
  while IFS=';' read -r daily_date daily_title daily_question_id daily_question_link daily_difficulty; do
    [[ -z "$daily_date" ]] && continue
    
    # format title (replace hyphens with spaces)
    formatted_daily_title="${daily_title//-/ }"
    
    # check if we need a new month header
    current_month="${daily_date%-*}"  # Extract YYYY-MM
    
    if [[ "$previous_month" != "$current_month" ]]; then
      # close previous table if not first iteration
      if [[ -n "$previous_month" ]]; then
        all_content+="</div>"
        bit=0
      fi
      
      # add new month header
      month_year=$(date +'%B %Y' -d "$daily_date")
      echo "- created $month_year"
      all_content+="<br><h2>$month_year<span>:</span></h2><div class=\"table\">"
      previous_month="$current_month"
    fi
    
    # build row HTML
    href="<a href=\"leetcode/${daily_date}.html\"><b>$daily_question_id</b><span>.</span> $formatted_daily_title</a>"
    
    if [[ $bit == 0 ]]; then
      class="row"
    else
      class="row dark"
    fi
    
    all_content+="<div class=\"$class $daily_difficulty\">$href <time>$daily_date</time> <difficulty class=\"$daily_difficulty\">$daily_difficulty</difficulty></div>"
    bit=$((bit ^ 1))
  done <<< "$sorted_data"
  
  # close final table
  if [[ -n "$previous_month" ]]; then
    all_content+="</div>"
  fi
  
  # single sed operation to replace all content
  pattern="<!-- CONTENT -->"
  escaped_content=$(echo "$all_content" | sed 's/[[\.*^$()+?{|]/\\&/g')
  sed -i "s|$pattern|$escaped_content|g" "$dest/../leetcode.html"

else
  # single file processing mode
  DATE=$1
  
  # convert date format and determine paths
  formatted_date="${DATE//\//-}"
  html_file="$dest/${formatted_date}.html"
  echo "html_file: $html_file"
  
  folder="${DATE%/*}"  # extract folder from date
  folder="${folder//\//-}"  # replace / with -
  src_file="$dir/$folder/${formatted_date}.md"
  echo "src_file: $src_file"
  
  if [ -f "$src_file" ]; then
    echo "src_file is PRESENT"
    
    # load frontmatter
    pandoc -s "$src_file" -o "$src_file.tmp.html" --template="$dir/frontmatter.bash" --mathml
    source "$src_file.tmp.html"
    
    # compile file
    output=$(basename "${src_file%.md}.html")
    pandoc -s "$src_file" -o "$dest/$output" \
        --template="$dir/daily-template.html" \
        --mathml \
        --variable="formatted_date:$formatted_date"
    
    # clean up
    rm -f "$src_file.tmp.html"
  else
    echo "src_file is NOT present"
  fi
fi
