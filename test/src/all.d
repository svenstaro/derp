import std.string;
import std.file;
import std.process;
import std.stdio;

void main() {
    bool ok = true;
    foreach(string f; dirEntries("bin/", SpanMode.shallow)) {
        if(f.startsWith("bin/test-") && f != "bin/test-all") {
            if(system(f) != 0)
                ok = false;
        }
    }

    if(ok)
        writeln(">> All tests OK.");
}
