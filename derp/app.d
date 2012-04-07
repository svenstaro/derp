module derp.app;

import std.stdio;
import std.datetime;

import luad.all;

import derp.fs;
import derp.resources;
import derp.scene;

static string Version = "0.1";

class Derp {
    ResourceManager resourceManager;
    LuaState lua;

    /// Is being set to false when the main loop should end.
    bool running = false;

    /// Called when the game is being started.
    void delegate() loadCallback;

    /// Called instead of the default main loop, if provided.
    void delegate() runCallback;

    /// Called in the main loop when updating.
    void delegate(double) updateCallback;

    /// Called in the main loop for drawing.
    void delegate() drawCallback;

    /// Called when the main loop ends.
    void delegate() quitCallback;

    /// Constructor
    this() {
        writeln("Derpy is coming!");

        this.resourceManager = new ResourceManager();

        // Create Lua State
        lua = new LuaState;
        lua.openLibs();
        lua.setPanicHandler((LuaState lua, in char[] error){
            writeln("====================================");
            writeln("LUA ERROR: ", error);
            writeln("====================================");
        });

        lua["derp"] = lua.newTable;
        lua["derp", "app"] = this;

        lua.doString("loadfile = function(src)
                return derp.app:luaLoad(src, \"\")
            end");
        lua.doString("function dofile(src)
                loadfile(src)()
            end");
        lua.doString("table.insert(
            package.loaders, 2, function(src)
                f = derp.app:luaLoad(src .. \".lua\", src)
                return f
            end)");

        lua.registerType!Node;

        // Initialize OpenGL
        // DerelictGL3.load();
    }

    LuaFunction luaRequire(string source) {
        return this.luaLoad(source ~ ".lua", source);
    }

    LuaFunction luaLoad(string source, string name = "") {
        Resource r = this.resourceManager.load(source, name == "" ? Autodetect : name);
        return lua.loadString(r.text);
    }

    /// Starts the game.
    void run() {
        if(loadCallback) {
            loadCallback();
        }

        if(runCallback) {
            runCallback();
        } else {
            mainLoop();
        }

        if(quitCallback) {
            quitCallback();
        }
    }

    /// Cancels the main loop and quits the game.
    void quit() {
        running = false;
    }

    void mainLoop() {
        running = true;
        StopWatch clock;
        clock.start();
        while(running) {
            // Time keeping here
            TickDuration t = clock.peek();
            clock.reset();
            double delta_time = 1.0 * t.length / t.ticksPerSec;

            // Update everything
            if(updateCallback) {
                updateCallback(delta_time);
            }

            // Clear here automatically

            // DRAW
            if(drawCallback) {
                drawCallback();
            }

            // Flip here automatically
        }
    }
}

