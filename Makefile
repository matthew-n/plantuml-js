BIN = "./node_modules/.bin"

build: grammar
	@mkdir -p dist
	@mkdir -p lib
	@cat `./bin/tree.sh src/plantuml-js.pegjs src/` > lib/plantuml-js.pegjs
	@$(BIN)/pegjs --allowed-start-rules start lib/plantuml-js.pegjs dist/plantuml-js.js

test: build
	@$(BIN)/mocha -c

clean:
	@rm -rf lib dist