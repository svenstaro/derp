BIN=bin/
COMPILER=dmd -od$(BIN)

# Aliases
default: bake
bake: Derp Derper HerpDerp
lib: Derp
bin: Derper
editor: HerpDerp

# Compiler Instructions
Derp:
	$(COMPILER) derp/*.d -oflibderp.a -lib

Derper:
	$(COMPILER) derper/*.d -I$(BIN) -L-L$(BIN) -L-lderp -ofbin/derper

HerpDerp:
	$(COMPILER) herpderp/*.d -I$(BIN) -L-L$(BIN) -L-lderp -ofbin/herpderp
