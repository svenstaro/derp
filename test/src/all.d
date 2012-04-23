import std.string;
import std.file;
import std.process;
import std.stdio;

void main() {
    foreach(string f; dirEntries("bin/", SpanMode.shallow)) {
        if(f.startsWith("bin/test-") && f != "bin/test-all") {
            shell(f);
        }
    }
}