BIN = "./node_modules/.bin"

build:
	mkdir -p dist
	cat `./bin/tree.sh grammar/plantuml-js.pegjs grammar/` >> temp.pegjs
	$(BIN)/pegjs --allowed-start-rules start temp.pegjs lib/parser.js

test: build
	$(BIN)/mocha -c
	
clean:
	rm -rf dist temp.pegjs lib/parser.js
