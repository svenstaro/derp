BIN=bin/
COMPILER=dmd -od$(BIN)
INCLUDES=-Iderp/ -Iexternals/LuaD/ 
DFLAGS=

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
	$(COMPILER) derp/*.d $(INCLUDES) -L-Lexternals/LuaD/lib/ -L-lluad -L-llua -oflibderp.a -lib

Derper:
	$(COMPILER) derper/*.d $(INCLUDES) -L-L$(BIN) -L-lderp -ofbin/derper

HerpDerp:
	$(COMPILER) herpderp/*.d $(INCLUDES) -L-L$(BIN) -L-lderp -ofbin/herpderp

GoDerper: Derper
	bin/derper
