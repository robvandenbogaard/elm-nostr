.phony: build

default: build

build:
	elm make --output public/main.js src/Main.elm
