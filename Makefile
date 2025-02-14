markdown:
	emacs -batch -l ./export.el

clean:
	rm content/*.md; rm -rf content/daily; rm -rf content/reference

veryclean: clean
	rm -rf public/*
