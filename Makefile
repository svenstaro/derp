default: dep prepare bake-force

clean:
	rm -r bin/ lib/*derp* build/

recompile: clean bake

dep:
	git submodule update --init
	cd externals/gl3n && make
	cd externals/LuaD && make
	cd externals/dbs && make
	cd externals/orange && make
	cd externals/Derelict3/build && dmd derelict.d && ./derelict

prepare:
	dmd -Iexternals/dbs -L-Lexternals/dbs/lib/ -L-ldbs compile.d -ofcompile

bake-force:
	./compile -fj 4

bake:
	./compile -j 4

test: bake
	bin/test-all
