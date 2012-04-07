module derp.core.fs;

import core.exception;

import std.stdio;
import std.conv;
import std.path;
import std.file;
import std.algorithm;
import std.zip;

class FileNotFoundException : Exception {
    string file;
    AbstractFileSystem fileSystem;

    this(string file, AbstractFileSystem fileSystem) {
        super("File " ~ file ~ " not found.");
        this.file = file;
        this.fileSystem = fileSystem;
    }
}

abstract class AbstractFileSystem {
    bool exists(string file);
    void[] read(string file);
    ulong getSize(string file);
    string[] list(bool deep = false);

    string readText(string file) {
        return to!string(cast(char[]) this.read(file));
    }

    ubyte[] readBytes(string file) {
        return cast(ubyte[]) this.read(file);
    }
}

class MergedFileSystem : AbstractFileSystem {
    AbstractFileSystem[] fileSystems;

    bool exists(string file) {
        return !(this._getFileSystem(file) is null);
    }

    void[] read(string file) {
        AbstractFileSystem afs = this._getFileSystem(file);
        if(afs) return afs.read(file);
        throw new FileNotFoundException(file, this);
    }

    ulong getSize(string file) {
        AbstractFileSystem afs = this._getFileSystem(file);
        if(afs) return afs.getSize(file);
        throw new FileNotFoundException(file, this);
    }

    string[] list(bool deep = false) {
        string[] list;

        foreach_reverse(fs; this.fileSystems) {
            foreach(l; fs.list) {
                if(!canFind(list, l))
                    list ~= l;
            }
        }

        return list;
    }

private:
    AbstractFileSystem _getFileSystem(string file) {
        foreach_reverse(f; this.fileSystems) {
            if(f.exists(file)) return f;
        }
        return null;
    }
}

class FileSystem : AbstractFileSystem {
    string rootPath;

    this(string rootPath) {
        this.rootPath = rootPath;
    }

    bool exists(string file) {
        string path = this._getPath(file);
        return std.file.exists(path);
    }

    void[] read(string file) {
        string path = this._getPath(file);
        try {
            return std.file.read(path);
        } catch (FileException) {
            throw new FileNotFoundException(file, this);
        }
    }

    ulong getSize(string file) {
        string path = this._getPath(file);
        try {
            return std.file.getSize(path);
        } catch (FileException) {
            throw new FileNotFoundException(file, this);
        }
    }

    string[] list(bool deep = false) {
        string[] list;
        try {
            auto dir = std.file.dirEntries(this.rootPath, deep ? SpanMode.breadth : SpanMode.shallow);
            foreach(string d; dir) {
                list ~= d[this.rootPath.length + 1 .. $];
            }
        } catch (FileException) {
            throw new FileNotFoundException(this.rootPath, this);
        }
        return list;
    }

private:
    string _getPath(string file) {
        return buildPath(this.rootPath, file);
    }
}

class ZipFileSystem : AbstractFileSystem {
    ZipArchive archive;

    this(ubyte[] data) {
        archive = new ZipArchive(data);
    }

    bool exists(string file) {
        try {
            auto x = this.archive.directory[file];
            return true;
        } catch (RangeError) {
            return false;
        }
    }

    void[] read(string file) {
        return archive.expand(_getMember(file));
    }

    ulong getSize(string file) {
        return _getMember(file).expandedSize;
    }

    string[] list(bool deep = false) {
        foreach(m; this.archive.directory) {
            writeln(m.name);
        }
        return []; // this.archive.directory;
    }

private:
    ArchiveMember _getMember(string file) {
        try {
            return this.archive.directory[file];
        } catch (RangeError) {
            throw new FileNotFoundException(file, this);
        }
    }
}
