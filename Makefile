
.PHONY: default
default: round.test

.PHONY: deps
deps:
	haxelib git winnepego file:///home/mchadwick/src/winnepego

.PHONY: round.test
round.test:
	@haxe \
		--interp \
		-lib buddy \
		-lib utest \
		-lib winnepego \
		-cp src \
		-cp test \
		-main round.Suite
