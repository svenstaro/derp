default: compile

clean:
	rm bin/* && rm lib/libderp.a

recompile:
	rm bin/* && rm lib/libderp.a && make

dep:
	git submodule update --init
	cd externals/gl3n && make
	cd externals/LuaD && make
	cd externals/dbs && make
	cd externals/orange && make
	cd externals/Derelict3/build && dmd derelict.d && ./derelict

prepare:
	dmd -Iexternals/dbs -L-Lexternals/dbs/lib/ -L-ldbs compile.d -ofcompile

compile:
	./compile
