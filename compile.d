/**
 * Builds Derp using the DBS library.
 *
 * Run it like this:
 * # rdmd -Iexternals/dbs -L-Lexternals/dbs/lib/ -L-ldbs build.d
 */

import std.stdio;
import std.string;
import std.range;
import std.algorithm;
import std.file;
import std.array;

import dbs.all;

int main(string[] args) {
    string docString = "-D -Dddocs/%s/";

    Settings.LibraryPath = "lib/";
    Settings.ExecutablePath = "bin/";
    Settings.ObjectFilePath = "build/";
    Settings.SelectedCompiler = Compiler.DMD;
    Settings.CompilerFlags = "-fPIC -g -gc -gs -unittest";
    Settings.getOpt(args);

    SystemDependency luajit = new SystemDependency("luajit-5.1");
    SystemDependency dl = new SystemDependency("dl");
    SystemDependency curl = new SystemDependency("curl");

    External gl3n = new External("gl3n", "cd externals/gl3n; make");
    gl3n.linkNames = ["gl3n-dmd"];
    gl3n.linkPaths = ["externals/gl3n/lib"];
    gl3n.includePaths = ["externals/gl3n/import/"];

    External luad = new External("luad", "cd externals/LuaD; make");
    luad.linkNames = ["luad"];
    luad.linkPaths = ["externals/LuaD/lib"];
    luad.includePaths = ["externals/LuaD/"];

    External orange = new External("orange", "cd externals/orange; make");
    orange.linkNames = ["orange"];
    orange.linkPaths = ["externals/orange/lib/64/", "externals/orange/lib/32/"];
    orange.includePaths =  ["externals/orange"];

    External derelict = new External("derelict", "cd externals/Derelict3/build; rdmd derelict.d");
    derelict.linkNames = ["DerelictAL", "DerelictFT", "DerelictGL3", "DerelictGLFW3", "DerelictIL", "DerelictUtil"];
    derelict.linkPaths = ["externals/Derelict3/lib/"];
    derelict.includePaths = ["externals/Derelict3/import/"];


    Dependency[string] list;

    Target derp = new Target("derp", TargetType.StaticLibrary);
    list["derp"] = derp;
    derp.createModulesFromDirectory("derp/");
    derp.dependencies ~= [cast(Dependency)luajit, dl, curl, luad, orange, derelict, gl3n];

    Target derper = new Target("derper");
    list["derper"] = derper;
    derper.createModulesFromDirectory("derper/");
    derper.dependencies ~= [cast(Dependency)derp, luad, derelict, gl3n];
    derper.flags = format(docString, "derper");

    Target herpderp = new Target("herpderp");
    list["herpderp"] = herpderp;
    herpderp.createModulesFromDirectory("herpderp/");
    herpderp.dependencies ~= [cast(Dependency)derp, luad, derelict, gl3n];
    derper.flags = format(docString, "herpderp");

    foreach(string f; dirEntries("test/src/", SpanMode.shallow)) {
        string name = "test-" ~ f[f.lastIndexOf('/') + 1 .. $ - 2];

        Target test = new Target(name);
        list[name] = test;
        test.addModule(f);
        test.dependencies ~= [cast(Dependency)derp, luad, derelict, gl3n];
    }

    string[] targets = args[1 .. $];

    if(!targets.length)
        targets = list.keys;

    // list["tests"] = derp;

    foreach(t; targets) {
        if(t in list) {
            if(!list[t].build()) {
                return 1;
            }
        } else {
            writeln(sWrap("Could not find target " ~ t ~ ". Stopping.", Color.Red, Style.Bold));
            return 1;
        }
    }

    return 0;
}
