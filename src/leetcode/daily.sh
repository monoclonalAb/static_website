#!/bin/bash

# magic variables (run from the main directory)
dir=src/leetcode
if [ -z "$1" ]; then
    echo "No date provided. Using default (today's date)."
    DATE=$(date -u +"%Y/%m/%d")
else
    DATE=$1
fi

# initialize the folder the daily will be in
# (the format is %Y-%m e.g. 2025-02)
folder=$(echo $DATE | cut -d '/' -f 1-2 | sed 's|\/|-|')

mkdir -p $dir/$folder
echo "$dir/$folder/${DATE//\//-}.md"

if [ ! -e "$dir/$folder/${DATE//\//-}.md" ]; then
    echo 'Creating new daily markdown'

    year=$(echo $DATE | cut -d '/' -f 1)
    month=$(echo $DATE | cut -d '/' -f 2)
    # remove leading zeros
    month=$(echo $month | sed 's/^0//')

    curl -X POST 'https://leetcode.com/graphql' \
        -e 'https://ericzheng.nz/' \
        -H "Content-Type: application/json" \
        -d '{
            "query":"\n    query dailyCodingQuestionRecords($year: Int!, $month: Int!) {\n  dailyCodingChallengeV2(year: $year, month: $month) {\n    challenges {\n      date\n     link\n      question {\n        questionFrontendId\n        title\n       difficulty\n       }\n    }\n }\n}\n    ",
            "variables":{"year":'"$year"',"month":'"$month"'},
            "operationName":"dailyCodingQuestionRecords"
        }' \
        -o $dir/month.json

    jq --arg DATE "${DATE//\//-}" '
        .data.dailyCodingChallengeV2.challenges[] | 
        select(.date == $DATE) | 
        {
            title: .question.title,
            question_id: .question.questionFrontendId,
            link: ("https://leetcode.com" + .link),
            difficulty: .question.difficulty
        }
    ' "$dir/month.json" > "$dir/daily.json"

    title=$(grep -oP '"title":\s*"\K[^"]+' $dir/daily.json)
    formatted_title=$(echo "$title" | sed 's/ /-/g')
    question_id=$(grep -oP '"question_id":\s*"\K[^"]+' $dir/daily.json)
    question_link=$(grep -oP '"link":\s*"\K[^"]+' $dir/daily.json)
    difficulty=$(grep -oP '"difficulty":\s*"\K[^"]+' $dir/daily.json)
    echo -e "---\ntitle: \"$formatted_title\"\nquestion_id: \"$question_id\"\nquestion_link: \"$question_link\"\ndifficulty: \"$difficulty\"\n---\n\n# cod<span>e</span>\n\n\`\`\`{.cpp}\n\n\`\`\`\n\n## complexit<span>y</span>\n\n:::sidebar\n- Time:\n- Space:\n:::\n\n## learning<span>s</span>\n\n:::sidebar\n\n:::\n\n## time take<span>n</span>\n\n:::sidebar\n\n:::$q" > $dir/$folder/${DATE//\//-}.md
else
    echo 'Markdown file exists for: '$DATE
fi

rm -rf $dir/month.json
rm -rf $dir/daily.json
