all:
	make fetch
	make generate

generate:
	tuist generate
	xed .

fetch:
	tuist fetch

clean:
	tuist clean
	rm -rf PRtify.xc*
	rm -rf Derived/
