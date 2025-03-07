GO = ~/go/bin/go
HUGO = ~/bin/hugo

markdown:
	emacs -batch -l ./export.el

backlinks:
	mkdir -p assets/data; $(GO) run backlinks.go ~/org-roam-garden

clean:
	rm content/*.md; rm -rf content/daily; rm -rf content/reference

cleanout:
	rm -rf public/*

veryclean:
	make clean && make cleanout

serve:
	$(HUGO) server -D

build:
	$(HUGO) build

all:
	make markdown && make backlinks && make build

allserve:
	make markdown && make backlinks && make serve
