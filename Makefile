BIN = "./node_modules/.bin"

build:
	@mkdir -p dist
	@cat `./bin/tree.sh grammar/plantuml-js.pegjs grammar/` > grammar/temp.pegjs
	@$(BIN)/pegjs --allowed-start-rules start grammar/temp.pegjs lib/parser.js

test: build
	@$(BIN)/mocha -c
	
docs: build
	@cp lib/plantuml-js.pegjs docs/

clean:
	@rm -rf lib dist
