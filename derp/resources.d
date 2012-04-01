module derp.resources;

import std.stdio;
import std.regex;
import std.file;
import std.net.curl;

static string Autodetect = "";

class Resource {
    string sourceType;
    string name;
    char[] data;

    this(string name) {
        this.name = name;
    }
}

abstract class ResourceLoader {
    Resource opCall(string source, string name);

    string autodetectName(string source) {
        return source;
    }
}

class FilesystemResourceLoader : ResourceLoader {
    Resource opCall(string source, string name) {
        source = replace(source, regex("^file://", "i"), "");

        Resource r = new Resource(name);
        r.data = cast(char[]) std.file.read(source);
        return r;
    }

    string autodetectName(string source) {
        return replace(source, regex("^file://", "i"), "");
    }
}

class HttpResourceLoader : ResourceLoader {
    Resource opCall(string source, string name) {
        source = replace(source, regex("^https?://", "i"), "");

        Resource r = new Resource(name);
        r.data = cast(char[]) std.net.curl.get(source);
        return r;
    }

    string autodetectName(string source) {
        return replace(source, regex("^https?://", "i"), "");
    }
}

class ResourceManager {
    ResourceLoader[string] loaders;
    Resource[string] resources;
    string[string] sourceTypePatterns;
    string defaultSourceType = "";

    this() {
        registerLoader("filesystem", new FilesystemResourceLoader());
        registerLoader("http", new HttpResourceLoader());

        registerSourceTypePattern("filesystem", "^file://");
        registerSourceTypePattern("filesystem", "^/");
        registerSourceTypePattern("http", "^https?://");
    }

    void registerLoader(string sourceType, ResourceLoader loader) {
        // set default source type if this is the first loader added
        // usually this will be "filesystem"
        if(loaders.length == 0) {
            defaultSourceType = sourceType;
        }
        loaders[sourceType] = loader;
    }

    void registerSourceTypePattern(string sourceType, string pattern) {
        sourceTypePatterns[pattern] = sourceType;
    }

    Resource load(string source, string name = Autodetect, string sourceType = Autodetect) {
        // autodetect source type here
        if(sourceType == Autodetect) {
            foreach(p; sourceTypePatterns.keys) {
                auto r = regex(p, "i");
                if(match(source, r)) {
                    sourceType = sourceTypePatterns[p];
                    break;
                }
            }
            if(sourceType == Autodetect) {
                writeln("Could not Auto-Detect SourceType for " ~ source);
                writeln("  using default SourceType " ~ defaultSourceType);
                sourceType = defaultSourceType;
            } else {
                writeln("Auto-Detect SourceType: " ~ sourceType);
                writeln("  for " ~ source);
            }
        }

        if(!(sourceType in loaders)) {
            writeln("Cannot find ResourceLoader for SourceType " ~ sourceType);
            return null;
        }

        ResourceLoader l = loaders[sourceType];
        Resource r = l(source, name);
        r.sourceType = sourceType;

        // autodetect source type here
        if(name == Autodetect) {
            name = l.autodetectName(source);
        }
        resources[name]  = r;
        return r;
    }
}
