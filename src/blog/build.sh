#!/bin/bash
echo "BUILDING: blog.html"

# magic variables (run from the main directory)
dir=src/blog
dest=public/blog
mkdir -p "$dest"

# arrays to store post data (avoid temp files entirely)
declare -a post_data
declare -a post_dates

echo "Processing blog posts..."

# process all blog posts efficiently
while IFS= read -r -d '' subdir; do
    dir_name="${subdir##*/}"
    file="$subdir/${dir_name#*_}.md"
    
    # skip if file doesn't exist
    [[ ! -f "$file" ]] && continue
    
    # load frontmatter (removing --mathml gives a bunch of "errors")
    pandoc -s "$file" -o "$file.tmp.html" --template="$dir/frontmatter.bash" --mathml
    source "$file.tmp.html"
    
    # store post data and dates for sorting
    post_data+=("$doc_date;$doc_title;$file")
    post_dates+=("$doc_date")
    
    # compile file with date passed to template
    output="${file##*/}"
    output="${output%.md}.html"
    
    pandoc -s "$file" -o "$dest/$output" \
        --template="$dir/article-template.html" \
        --mathml --toc --toc-depth=2 \
        --variable="doc_date:$doc_date"
    
    # clean up temp file
    rm -f "$file.tmp.html"
done < <(find "$dir" -mindepth 1 -type d -print0)

# sort posts by date (reverse chronological)
printf '%s\n' "${post_data[@]}" | sort -r > /tmp/sorted_posts.$$

echo "GENERATING: blog posts"

# pre-build all HTML content in one pass
blog_content=""
bit=0

while IFS=';' read -r doc_date doc_title doc_file; do
    [[ -z "$doc_date" ]] && continue
    
    echo "$doc_date: $doc_title"
    
    # Use parameter expansion for efficiency
    doc_link="${doc_file%.md}.html"
    doc_basename="${doc_link##*/}"
    
    # Format date once
    reformatted_doc_date=$(date +'%B %d, %Y' -d "$doc_date")
    
    # Build href with proper escaping
    href="<a href=\"blog/$doc_basename\">$doc_title<span>.</span></a>"
    
    # Determine class
    if [[ $bit == 0 ]]; then
        class="row sidebar"
    else
        class="row dark"
    fi
    
    # Build content string (no double escaping needed)
    blog_content+="<div class=\"$class\">$href <time>$reformatted_doc_date</time></div>"
    bit=$((bit ^ 1))
done < /tmp/sorted_posts.$$

# clean up temp file
rm -f /tmp/sorted_posts.$$

# build final table content
table_content="<div class=\"table\">$blog_content</div>"

# use safer replacement method
pattern="<!-- CONTENT -->"
temp_content=$(mktemp)
echo "$table_content" > "$temp_content"

# replace content using file insertion (most reliable)
sed -i "/$pattern/r $temp_content" "$dest/../blog.html"
sed -i "/$pattern/d" "$dest/../blog.html"

# clean up
rm -f "$temp_content"
