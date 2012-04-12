default: compile

prepare:
	dmd -Iexternals/dbs -L-Lexternals/dbs/lib/ -L-ldbs build.d -ofbuild

compile:
	./build
