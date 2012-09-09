default: compile

clean:
	[[ -d build ]] && rm -r build
	[[ -d bin ]] && rm -r bin
	[[ -d lib ]] && rm -r lib

dependencies:
	git submodule update --init
	cd externals/gl3n && make
	cd externals/LuaD && make
	cd externals/dbs && make
	cd externals/orange && make
	cd externals/Derelict3/build && rdmd derelict.d

cmake:
	mkdir -p build/
	cd build && cmake -DCMAKE_D_COMPILER=dmd ..

compile: cmake
	cd build && make -j4
