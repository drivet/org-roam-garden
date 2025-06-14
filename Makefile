GO = ~/go/bin/go
HUGO = ~/bin/hugo

orgfiles:
	emacs -batch -l ./export.el
	mv ~/org-roam-garden/books.html ~/org-roam-garden/content/books.html

backlinks:
	mkdir -p assets/data; $(GO) run backlinks.go ~/org-roam-garden; sed -i 's/_index/index/g' assets/data/backlinks.yaml

clean:
	rm content/*.md; rm content/*.html; rm -rf content/daily; rm -rf content/reference

cleanout:
	rm -rf public/*

veryclean:
	make clean && make cleanout

serve:
	$(HUGO) server -D

build:
	$(HUGO) build

all:
	make orgfiles && make backlinks && make build

allserve:
	make orgfiles && make backlinks && make serve
