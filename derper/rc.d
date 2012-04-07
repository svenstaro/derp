module derper.rc;

import std.stdio;
import std.file;
import std.path;
import std.zip;
import std.string;

import derp.all;
import std.process;

version(Windows) {
    enum tmpDir = "C:/Windows/Temp/";
} version(Posix) {
    enum tmpDir = "/tmp/";
} else {

}

string getUnusedFilename(string dir, string name, string ext) {
    string f = std.path.buildPath(dir, name ~ (ext ? "." ~ ext : ""));
    int i = 0;
    while(std.file.exists(f)) {
        i++;
        f = std.path.buildPath(dir, std.string.format("%s-%i", name, i) ~ (ext ? "." ~ ext : ""));
    }
    return f;
}

class TemporaryFile {
    string name;

    this(string name = "resource-compiler", string ext = "zip") {
        this.name = getUnusedFilename(tmpDir, name, ext);
    }

    delete(void* obj) {
        (cast(TemporaryFile)obj).remove();
    }

    void remove() {
        std.file.remove(this.name);
    }
}

void compileResources(string[] resources, string binaryFile, string outputFile, bool recursive = false, string resource_root = "") {
    ZipArchive archive = new ZipArchive();

    string[] files;

    foreach(r; resources) {
        if(std.file.isDir(r) && recursive) {
            foreach(string f; std.file.dirEntries(r, SpanMode.breadth))
                if(std.file.isFile(f))
                    files ~= f;
        } else if(std.file.isFile(r)) {
            files ~= r;
        }
    }

    foreach(f; files) {
        ArchiveMember am = new ArchiveMember();
        string fn = f;
        std.algorithm.skipOver(fn, resource_root);
        am.name = fn;
        if(resource_root != "" && fn == f) {
            writefln("Warning: %s is not in resource root %s. Adding as %s instead.", f, resource_root, f);
        }
        am.expandedData = cast(ubyte[]) std.file.read(f);
        archive.addMember(am);
    }

    ubyte[] archiveData = cast(ubyte[])archive.build();
    ubyte[] binaryData = cast(ubyte[])std.file.read(binaryFile);

    ulong[] header = [archiveData.length];

    if(std.file.exists(outputFile))
        std.file.remove(outputFile);
    std.file.write(outputFile, binaryData ~ archiveData ~ cast(ubyte[])header);

    version(Posix) {
        std.process.shell("chmod +x " ~ outputFile);
    }
}

ubyte[] extractZipArchiveFromBinary(ubyte[] binary) {
    ulong[] header = cast(ulong[]) binary[$ - 8 .. $];
    binary = binary[0 .. $ - 8];

    ulong archiveLength = header[0];

    ubyte[] data = binary[$ - archiveLength .. $];
    return data;
}
