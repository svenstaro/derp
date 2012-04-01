module derp.app;

import std.stdio;

import luad.all;

import orange.core._;
import orange.serialization._;
import orange.serialization.archives._;

import derelict.opengl3.gl3;
import derelict.glfw3.glfw3;

class Foo {
    int wut;
}

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

        DerelictGL3.load();
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

private:
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

            lua.doString(`print("derplua")`);

            auto foo = new Foo;
            foo.wut = 3;

            auto archive = new XmlArchive!(char);
            auto serializer = new Serializer(archive);

            serializer.serialize(foo);
            auto foo2 = serializer.deserialize!(Foo)(archive.untypedData);
            assert(foo.wut == foo2.wut);
        }
    }
}
