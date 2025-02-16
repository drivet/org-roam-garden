markdown:
	emacs -batch -l ./export.el

backlinks: markdown
	go run backlinks.go

clean:
	rm content/*.md; rm -rf content/daily; rm -rf content/reference

veryclean: clean
	rm -rf public/*

serve:
	hugo server -D
