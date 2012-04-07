module derper.main;

import std.stdio;
import std.conv;
import std.getopt;
import std.zip;
import std.algorithm;
import luad.all;
import derp.all;

import derper.loader;
import derper.rc;

int main(string[] args) {
    // parse arguments

    bool display_help, display_version, recursive;
    string resource_compiled, resource_root;

    getopt(args,
        std.getopt.config.bundling,
        std.getopt.config.caseSensitive,
        "R|resources", &resource_compiled,
        "p|resource-root", &resource_root,
        "r|recursive", &recursive,
        "h|help", &display_help,
        "v|version", &display_version);

    if(display_version) {
        writeln("Derp Engine Loader - Derper");
        writeln("Version " ~ derp.core.app.Version);
        return 0;
    }
    if(!resource_compiled && args.length > 2) {
        writeln("Too many input files.");
        display_help = true;
    }

    if(display_help) {
        writeln("derper - Derp Engine Runtime
Copyright (c) 2012 -- Paul Bienkowski, Sven-Hendrik Haase

Usage:
  derper [options]
  derper MAIN_ZIP_FILE
  derper -R BINARY_OUTPUT [-r] [-p PATH] RESOURCE_FILES

        -v  --version               Shows the version
        -h  --help                  Shows this help
        -R  --resources OUT         Compiles the loader and the resource files into a single binary
        -r  --recursive             Reads directories
        -p  --resource-root PATH    Treats resources relative to PATH
");
        return 0;
    }

    if(resource_compiled) {
        compileResources(args[1 .. $], args[0], resource_compiled, recursive, resource_root);
        return 0;
    }

    Derp app = new Derp();

    ubyte[] data;
    if(args.length >= 2) {
        // Load the zipfile
        Resource zipFile = app.resourceManager.load(args[1]);
        data = zipFile.bytes;
    } else {
        // try to load from our own end ;)
        Resource zipFile = app.resourceManager.load(args[0]);
        data = extractZipArchiveFromBinary(zipFile.bytes);
    }

    Loader loader;
    try {
        loader = new Loader(app, data);
    } catch (ZipException) {
        writeln("Could not load ZIP file.");
    }

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
