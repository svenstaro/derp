module derper.loader;

import core.vararg;
import std.stdio;
import luad.all;
import derp.all;

class Loader {

    Derp derp;
    string filename;

    this(Derp derp, string filename) {
        this.derp = derp;
        this.filename = filename;
    }

    void prepareState() {
        this.derp.lua["derp", "load"] = () {};
        this.derp.lua["derp", "draw"] = () {};
        this.derp.lua["derp", "update"] = (float dt) {};
        this.derp.lua["derp", "quit"] = () {};

        derp.loadCallback = &luaLoad;
        derp.drawCallback = &luaDraw;
        derp.updateCallback = &luaUpdate;
        derp.quitCallback = &luaQuit;
    }

    void doFile() {
        derp.lua.doFile(filename);
    }

    void luaLoad() {
        auto lt = derp.lua.get!LuaTable("derp");
        auto lf = lt.get!LuaFunction("load");
        lf();
    }

    void luaDraw() {
        auto lt = derp.lua.get!LuaTable("derp");
        auto lf = lt.get!LuaFunction("draw");
        lf();
    }

    void luaUpdate(float dt) {
        auto lt = derp.lua.get!LuaTable("derp");
        auto lf = lt.get!LuaFunction("update");
        lf(dt);
    }

    void luaQuit() {
        auto lt = derp.lua.get!LuaTable("derp");
        auto lf = lt.get!LuaFunction("quit");
        lf();
    }
}
