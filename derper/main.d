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
    }

    if(display_help) {
        writeln("Display help...");
        return 0;
    }

    Derp app = new Derp();

    ubyte[] data;
    if(args.length >= 2) {
        // Load the zipfile
        Resource zipFile = app.resourceManager.load(args[1]);
        data = zipFile.bytes;
    }
    Loader loader = new Loader(app, data);

    loader.prepareState();
    try {
        loader.doFile();
    } catch(FileNotFoundException e) {
        if(e.file == "main.lua") {
            writeln("Cannot find `main.lua`.");
            if(args.length == 1) {
                writeln("Please create main.lua in this directory or add it to a zip archive and call derper with this archive.");
            } else {
                writeln("The archive you supplied did not contain a file main.lua.");
            }
            return 1;
        }
    }
    app.run();

    return 0;
}
