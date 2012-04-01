COMPILER=dmd 
INCLUDES=-I. -Iexternals/LuaD/ -Iexternals/orange/ -Iexternals/Derelict3/import/
LFLAGS=-L-Lexternals/LuaD/lib/ -L-lluad -L-lluajit-5.1 -L-Lexternals/orange/lib/64/ -L-Lexternals/orange/lib/32/ -L-lorange -L-Lexternals/Derelict3/lib/ -L-lDerelictAL -L-lDerelictFT -L-lDerelictGL3 -L-lDerelictGLFW3 -L-lDerelictIL -L-lDerelictUtil -L-ldl -L-lcurl
DFLAGS=-odlib/ -debug -gc -op

# Aliases
default: bake
bake: Derp Derper HerpDerp
lib: Derp
bin: Derper
editor: HerpDerp

# Compiler Instructions
luad:
	cd externals/LuaD; make

orange:
	cd externals/orange; make

derelict:
	cd externals/Derelict3/build; rdmd derelict.d

deps: luad orange derelict

Derp: 
	$(COMPILER) derp/*.d $(DFLAGS) $(INCLUDES) $(LFLAGS) -oflibderp.a -lib

Derper:
	$(COMPILER) derper/*.d $(DFLAGS) $(INCLUDES) -L-Llib/ -L-lderp $(LFLAGS) -ofbin/derper

HerpDerp:
	$(COMPILER) herpderp/*.d $(DFLAGS) $(INCLUDES) -L-Llib -L-lderp $(LFLAGS) -ofbin/herpderp

GoDerper: Derper
	bin/derper test/derp.lua
