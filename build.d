/**
 * Builds Derp using the DBS library.
 *
 * Run it like this:
 * # rdmd -Iexternals/dbs -L-Lexternals/dbs/lib/ -L-ldbs build.d
 */

import std.stdio;
import std.string;
import std.algorithm;

import dbs.all;

int main(string[] args) {
    string docString = "-D -Dddocs/%s/";

    Settings.LibraryPath = "lib/";
    Settings.ExecutablePath = "bin/";
    Settings.SelectedCompiler = Compiler.DMD;
    Settings.CompilerFlags = "-fPIC -g -gc -gs -unittest";
    Settings.getOpt(args);

    Dependency luajit = new Dependency("luajit-5.1");
    Dependency dl = new Dependency("dl");
    Dependency curl = new Dependency("curl");

    External gl3n = new External("gl3n", "cd externals/gl3n; make",
        ["gl3n-dmd"], ["externals/gl3n/lib/"], ["externals/gl3n/import/"]);
    External luad = new External("luad", "cd externals/LuaD; make",
        [], ["externals/LuaD/lib/"], ["externals/LuaD/"]);
    External orange = new External("orange", "cd externals/orange; make",
        [], ["externals/orange/lib/64/", "externals/orange/lib/32/"],
        ["externals/orange"]);
    External delerict = new External("delerict", "cd externals/Derelict3/build; rdmd derelict.d", [
        "DerelictAL", "DerelictFT", "DerelictGL3", "DerelictGLFW3", "DerelictIL", "DerelictUtil"],
        ["externals/Derelict3/lib/"], ["externals/Derelict3/import/"]);

    Target derp = new Target("derp", "derp/", "", TargetType.StaticLibrary,
        [luajit, dl, curl, luad, orange, delerict, gl3n], format(docString, "derp"));
    Target derper = new Target("derper", "derper/", "", TargetType.Executable,
        [cast(Dependency)derp, luad, delerict, gl3n], format(docString, "derper"));
    Target herpderp = new Target("herpderp", "herpderp/", "", TargetType.Executable,
        [cast(Dependency)derp, luad, delerict, gl3n], format(docString, "herpderp"));

    string[] targets = args[1 .. $];

    if(!targets.length)
        targets = ["derp", "derper", "herpderp"];

    Dependency[string] list;
    list["derp"] = derp;
    list["derper"] = derper;
    list["herpderp"] = herpderp;
    // list["tests"] = derp;

    foreach(t; targets) {
        if(t in list) {
            if(!list[t].prepare()) {
                return 1;
            }
        } else {
            writeln(sWrap("Could not find target " ~ t ~ ". Stopping.", Color.Red, Style.Bold));
            return 1;
        }
    }

    return 0;
}
