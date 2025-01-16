site:
	./build.sh

clean:
	rm -rf public && mkdir -p public

daily:
	./src/leetcode/daily.sh

# python3 -m http.server = starts HTTP servier using Python 3
# 4000 = port 4000
# -d public = serves files from public/ available to clients that access the server
serve:
	python3 -m http.server 4000 -d public
