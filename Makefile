BIN=bin/
COMPILER=dmd -od$(BIN)
INCLUDES=-I. -Iexternals/LuaD/
LFLAGS=-L-Lexternals/LuaD/lib/ -L-lluad -L-lluajit-5.1
DFLAGS=-w

# Aliases
default: bake
bake: Derp Derper HerpDerp
lib: Derp
bin: Derper
editor: HerpDerp

# Compiler Instructions
luad:
	cd externals/LuaD; make

Derp: luad
	$(COMPILER) derp/*.d $(DFLAGS) $(INCLUDES) $(LFLAGS) -oflibderp.a -lib

Derper:
	$(COMPILER) derper/*.d $(DFLAGS) $(INCLUDES) -L-L$(BIN) -L-lderp $(LFLAGS) -ofbin/derper

HerpDerp:
	$(COMPILER) herpderp/*.d $(DFLAGS) $(INCLUDES) -L-L$(BIN) -L-lderp $(LFLAGS) -ofbin/herpderp

GoDerper: Derper
	bin/derper
