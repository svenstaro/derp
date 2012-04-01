module derper.main;

import std.stdio;
import std.conv;
import std.getopt;
import luad.all;
import derp.all;
import derper.loader;

int main(string[] args) {
    // parse arguments

    bool help;
    getopt(args,
        std.getopt.config.bundling,
        "help|h", &help);



    if(args.length > 2) {
        writeln("Too many input files.");
        help = true;
    } else if(args.length == 1) {
        writeln("No input file.");
        help = true;
    }

    if(help) {
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
