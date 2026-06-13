GO = ~/go/bin/go
HUGO = ~/bin/hugo

orgfiles:
	emacs -batch -l ./export.el

backlinks:
	mkdir -p assets/data; $(GO) run backlinks.go ~/org-roam-garden; sed -i 's/_index/index/g' assets/data/backlinks.yaml

build:
	$(HUGO) build

all:
	make orgfiles && make backlinks && make build

clean:
	rm content/*.md
	rm content/*.html
	rm -rf content/daily
	rm -rf content/reference
	rm -rf .org-timestamps

cleanout:
	rm -rf public/*

veryclean:
	make clean && make cleanout

serve:
	$(HUGO) server -D

allserve:
	make orgfiles && make backlinks && make serve
