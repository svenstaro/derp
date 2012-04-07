module derper.loader;

import std.stdio;
import luad.all;
import derp.all;

class Loader {

    Derp derp;
    string filename;

    this(Derp derp, ubyte[] data = []) {
        this.derp = derp;

        if(data) {
            // Load the Zip File
            FilesystemResourceLoader fsr = cast(FilesystemResourceLoader) this.derp.resourceManager.loaders["filesystem"];
            fsr.fileSystem.fileSystems ~= new ZipFileSystem(data);
        }
    }

    void prepareState() {
        this.derp.lua["derp", "load"] = () {};
        this.derp.lua["derp", "draw"] = () {};
        this.derp.lua["derp", "update"] = (double dt) {};
        this.derp.lua["derp", "quit"] = () {};

        derp.loadCallback = &luaLoad;
        derp.drawCallback = &luaDraw;
        derp.updateCallback = &luaUpdate;
        derp.quitCallback = &luaQuit;
    }

    void doFile() {
        Resource main = this.derp.resourceManager.load("main.lua");
        derp.lua.doString(main.text);
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

    void luaUpdate(double dt) {
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
