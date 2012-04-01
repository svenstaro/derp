module derper.main;

import std.stdio;
import std.conv;
import std.getopt;
import luad.all;
import derp.all;
import derper.loader;

int main(string[] args) {
    // parse arguments

    bool display_help, display_version;
    getopt(args,
        std.getopt.config.bundling,
        "help|h", &display_help,
        "version|v", &display_version);

    if(display_version) {
        writeln("Derp Engine Loader - Derper");
        writeln("Version " ~ derp.app.Version);
        return 0;
    }

    if(args.length > 2) {
        writeln("Too many input files.");
        display_help = true;
    } else if(args.length == 1) {
        writeln("No input file.");
        display_help = true;
    }

    if(display_help) {
        writeln("Display help...");
        return 0;
    }

    Derp app = new Derp();
    Loader loader = new Loader(app, args[1]);
    loader.prepareState();
    loader.doFile();
    app.run();

    return 0;
}
