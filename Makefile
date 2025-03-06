markdown:
	emacs -batch -l ./export.el

backlinks:
	mkdir -p assets/data; go run backlinks.go

clean:
	rm content/*.md; rm -rf content/daily; rm -rf content/reference

cleanout:
	rm -rf public/*

veryclean:
	make clean && make cleanout

serve:
	hugo server -D

build:
	hugo build

all:
	make markdown && make backlinks && make build

allserve:
	make markdown && make backlinks && make serve
