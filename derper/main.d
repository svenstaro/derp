import std.stdio;
import std.conv;
import std.getopt;

import luad.all;

import derp.all;



float total_time = 0;
Derp app;

LuaFunction luaLoad, luaDraw, luaUpdate;

void load() {
    writeln("Loading...");
}

void draw() {
    writeln("Drawing...");
}

void update(float dt) {
    total_time += dt;
    writeln("Updating... " ~ to!string(dt));
    if(total_time > 4) {
        app.quit();
    }
}

int main(string[] args) {
    // parse arguments

    bool help;
    getopt(args,
        std.getopt.config.bundling,
        "help|h", &help);

    if(help) {
        writeln("Helping you...");
        return 0;
    }

    if(args.length > 2) {
        writeln("Too many input files.");
        return 1;
    } else if(args.length == 1) {
        writeln("No input file.");
        return 1;
    }

    string input = args[1];
    writeln("input file: " ~ input);

    app = new Derp();

    auto lua = new LuaState;
    lua.openLibs();
    lua.setPanicHandler((LuaState lua, in char[] error) {
        writeln("Lua Error:", error);
    });


    LuaTable luaDerp = lua.newTable;
    lua["derp"] =  luaDerp;
    lua["derp", "app"] = app;

    lua["derp", "draw"] = () {};
    lua["derp", "load"] = () {};
    lua["derp", "update"] = (float dt) {};

    lua.doFile(input);

    luaDraw = luaDerp.get!LuaFunction("draw");
    luaUpdate = luaDerp.get!LuaFunction("update");
    luaLoad = luaDerp.get!LuaFunction("load");

    app.drawCallback = function void() { luaDraw(); };
    app.updateCallback = function void(float dt) { luaUpdate(dt); };
    app.loadCallback = function void() { luaLoad(); };

    // draw, load, update
    app.run();

    return 0;
}
