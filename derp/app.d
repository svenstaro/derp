module derp.app;

import std.stdio;

import luad.all;

class Derp {
    /// Is being set to false when the main loop should end.
    bool running = false;

    /// Called when the game is being started.
    void function() loadCallback;

    /// Called instead of the default main loop, if provided.
    void function() runCallback;

    /// Called in the main loop when updating.
    void function(float) updateCallback;

    /// Called in the main loop for drawing.
    void function() drawCallback;

    /// Called when the main loop ends.
    void function() quitCallback;

    /// Constructor
    this() {
        writeln("Derpy is coming!");
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

            // Clear here automatically ?

            // DRAW
            if(drawCallback) {
                drawCallback();
            }

            // Flip here automatically ?

            auto lua = new LuaState;
            lua.openLibs();
            lua.setPanicHandler((LuaState lua, in char[] error) {
                writeln("Lua Error:", error);
            });

            // lua.registerType!Derp;
            lua["derp"] = lua.newTable;
            lua["derp", "app"] = this;

            lua.doString(`print("Quitting from Lua"); derp.app:quit()`);
        }
    }
    void lol(string msg) {
        writeln("LOL: " ~ msg);
    }
}

