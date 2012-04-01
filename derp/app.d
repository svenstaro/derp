module derp.app;

import std.stdio;

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
        }
    }
}
