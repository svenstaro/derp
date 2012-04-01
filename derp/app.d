module derp.app;

import std.stdio;

class Derp {
    /// Is being set to false when the main loop should end.
    bool running = false;

    void function() loadCallback;
    void function() runCallback;
    void function() drawCallback;
    void function(float) updateCallback;
    void function() quitCallback;

    this() {
        writeln("Derpy is coming!");
    }

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
