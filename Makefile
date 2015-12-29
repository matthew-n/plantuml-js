all: pegjs js test

pegjs:
	mkdir -p lib
	
js:
	mkdir -p dist
	node_modules/.bin/pegjs --allowed-start-rules start lib/plantuml-js.pegjs dist/plantuml-js.js

test:
	mocha -c
	
clean:
	rm -rf lib dist
	
.PHONY: all pegjs js test
