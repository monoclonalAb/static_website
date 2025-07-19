site:
	./build.sh $(PAGES)

clean:
	rm -rf public && mkdir -p public

# make daily => creates the daily leetcode md file for today
# make daily DATE=%Y/%m/%d e.g. DATE=2025/01/29 => creates the daily leetcode md file for the specified date
DEFAULT_DATE := $(shell date -u +'%Y/%m/%d')
daily:
	./src/leetcode/daily.sh $(if $(DATE),$(DATE),$(DEFAULT_DATE))

blog:
	./build.sh BLOG

leetcode:
	./src/leetcode/build.sh $(if $(DATE),$(DATE),)

# python3 -m http.server = starts HTTP servier using Python 3
# 4000 = port 4000
# -d public = serves files from public/ available to clients that access the server
serve:
	python3 -m http.server 4000 -d public
