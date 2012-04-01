module derp.app;

import std.stdio;

import luad.all;

static string Version = "0.1";

class Derp {
    LuaState lua;

    /// Is being set to false when the main loop should end.
    bool running = false;

    /// Called when the game is being started.
    void delegate() loadCallback;

    /// Called instead of the default main loop, if provided.
    void delegate() runCallback;

    /// Called in the main loop when updating.
    void delegate(float) updateCallback;

    /// Called in the main loop for drawing.
    void delegate() drawCallback;

    /// Called when the main loop ends.
    void delegate() quitCallback;

    /// Constructor
    this() {
        writeln("Derpy is coming!");

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

        // Initialize OpenGL
        // DerelictGL3.load();
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
        while(running) {
            // Time keeping here
            float delta_time = 0.5;

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

