markdown:
	emacs -batch -l ./export.el

backlinks:
	go run backlinks.go

clean:
	rm content/*.md; rm -rf content/daily; rm -rf content/reference

veryclean: clean
	rm -rf public/*

serve:
	hugo server -D

build:
	hugo build

all:
	make markdown && make backlinks && make build

allserve:
	make markdown && make backlinks && make serve
