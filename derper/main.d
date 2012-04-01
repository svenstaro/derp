import std.stdio;
import std.conv;

import derp.app;

float total_time = 0;
Derp app;

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

int main() {
    app = new Derp();
    app.drawCallback = &draw;
    app.loadCallback = &load;
    app.updateCallback = &update;
    app.run();
    return 0;
}
