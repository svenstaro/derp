default: compile

dep:
	git submodule update --init
	cd externals/gl3n && make
	cd externals/LuaD && make
	cd externals/dbs && make
	cd externals/orange && make
	cd externals/Derelict3/build && dmd derelict.d && ./derelict

prepare:
	dmd -Iexternals/dbs -L-Lexternals/dbs/lib/ -L-ldbs build.d -ofbuild

compile:
	./build
