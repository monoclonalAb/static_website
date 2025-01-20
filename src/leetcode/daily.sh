#!/bin/bash

# magic variables (run from the main directory)
dir=src/leetcode
today=$(date -u +'%Y/%m/%d')

mkdir -p $dir/$today

echo "$dir/$today/${today//\//-}.md"

if [ ! -e "$dir/$today/${today//\//-}.md" ]; then
    echo 'Creating new daily markdown'

    curl -X POST 'https://leetcode.com/graphql' \
        -e 'https://ericzheng.nz/' \
        -H "Content-Type: application/json" \
        -d '{"query":"\n    query questionOfToday {\n  activeDailyCodingChallengeQuestion {\n    date\n    userStatus\n    link\n    question {\n      titleSlug\n      title\n      translatedTitle\n      acRate\n      difficulty\n      freqBar\n      frontendQuestionId: questionFrontendId\n      isFavor\n      paidOnly: isPaidOnly\n      status\n      hasVideoSolution\n      hasSolution\n      topicTags {\n        name\n        id\n        slug\n      }\n    }\n  }\n}\n    ","variables":{},"operationName":"questionOfToday"}' \
        -o $dir/daily.json.tmp.html

    title=$(grep -oP '"title":\s*"\K[^"]+' $dir/daily.json.tmp.html)
    formatted_title=$(echo "$title" | sed 's/ /-/g')
    question_id=$(grep -oP '"frontendQuestionId":\s*"\K[^"]+' $dir/daily.json.tmp.html)
    question_link="https://leetcode.com$(grep -oP '"link":\s*"\K[^"]+' $dir/daily.json.tmp.html)"
    difficulty=$(grep -oP '"difficulty":\s*"\K[^"]+' $dir/daily.json.tmp.html)
    echo -e "---\ntitle: \"$formatted_title\"\nquestion_id: \"$question_id\"\nquestion_link: \"$question_link\"\ndifficulty: \"$difficulty\"\n---$q" > $dir/${today}/$(date -u +'%Y-%m-%d').md
else
    echo 'Markdown file exists'
fi

rm -rf $dir/daily.json.tmp.html
