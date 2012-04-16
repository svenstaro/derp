module derp.core.app;

import std.stdio;
import std.datetime;

import luad.all;

import derp.core.fs;
import derp.core.resources;
import derp.core.scene;

static string Version = "0.1";

/**
 * This is the main engine object. It connects all submodules and contains
 * the main loop.
 *
 * Examples:
 * ---
 * // This is all you need to run the main loop.
 * import std.stdio;
 * import std.functional;
 * import derp.all;
 *
 * Derp derp = new Derp();
 * derp.updateCallback = std.functional.toDelegate((double dt) {
 *     std.stdio.writefln("Updating... ", dt);
 * });
 * derp.run();
 * ---
 */
class Derp {
    /// The global resource manager
    ResourceManager resourceManager;

    /**
     * The main LuaState.
     *
     * This is filled with global properties (e.g. "derp.app") on initialization.
     */
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

        // lua.registerType!Node; // not compatible yet
    }

    /**
     * Replacement function for Lua's loadfile() and require()
     *
     * Parses the contents of the source into a lua function.
     *
     * Parameters:
     *      source = The filename of the LUA file (including extension)
     *               to load.
     *      name   = The resource name. Leave empty for Autodetect. Default: ""
     */
    LuaFunction luaLoad(string source, string name = "") {
        Resource r = this.resourceManager.load(source, name == "" ? Autodetect : name);
        return lua.loadString(r.text);
    }

    /**
     * Starts the game.
     *
     * This will eventually start either the default mainLoop, or call
     * the runCallback, if one was specified.
     */
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

    /**
     * Cancels the mainLoop and quits the game.
     *
     * For custom main loop implementations with runCallback, make sure
     * to check the running variable each frame and manually terminate
     * the loop.
     */
    void quit() {
        running = false;
    }

    /// The default main loop of the engine.
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

