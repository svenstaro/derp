/**
 * Module for resource loading from different sources.
 *
 * Todo: Merge with derp.fs and Resource class.
 */

module derp.core.resources;

import std.stdio;
import std.regex;
import std.file;
import std.conv;
import std.net.curl;

import derp.core.fs;

static string Autodetect = "";

/**
 * Holds resouce data after loading.
 */
class Resource {
    string sourceType;  /// The type of the source used to load this resource.
    string name;        /// The name of this resource.
    void[] data;        /// The actual resource data.

    /// Constructor
    this(string name) {
        this.name = name;
    }

    /// Returns the data as ubyte array.
    @property ubyte[] bytes() {
        return cast(ubyte[]) this.data;
    }

    /// Returns the data as text.
    @property string text() {
        return to!string(this.data);
    }
}

/**
 * Abstract class for custom resource loaders.
 */
abstract class ResourceLoader {
    /// Overwrite this to implement custom loading process.
    Resource opCall(string source, string name);

    /// Performs automatic name detection from a source string.
    string autodetectName(string source) {
        return source;
    }
}


/**
 * Loads a resource from a MergedFileSystem.
 */
class FilesystemResourceLoader : ResourceLoader {
    MergedFileSystem fileSystem; /// The MergedFileSystem to load resources from.

    /// Constructor
    this() {
        this.fileSystem = new MergedFileSystem();
        this.fileSystem.fileSystems ~= new FileSystem(""); // find files in current directory
    }

    Resource opCall(string source, string name) {
        source = replace(source, regex("^file://", "i"), "");

        Resource r = new Resource(name);
        r.data = this.fileSystem.read(source);
        return r;
    }

    string autodetectName(string source) {
        return replace(source, regex("^file://", "i"), "");
    }
}

/**
 * Loads a resource from a remote server via HTTP.
 */
class HttpResourceLoader : ResourceLoader {
    Resource opCall(string source, string name) {
        source = replace(source, regex("^https?://", "i"), "");

        Resource r = new Resource(name);
        r.data = std.net.curl.get(source);
        return r;
    }

    string autodetectName(string source) {
        return replace(source, regex("^https?://", "i"), "");
    }
}

/**
 * Loads and holds resources and registered resource loaders.
 */
class ResourceManager {
    ResourceLoader[string] loaders;     /// List of registered resource loaders.
    Resource[string] resources;         /// List of loaded resources.
    string[string] sourceTypePatterns;  /// List of patterns for automatic source type detection.
    string defaultSourceType = "";      /// Default source type, used if automatic detection fails.

    /**
     * Constructor.
     */
    this() {
        registerLoader("filesystem", new FilesystemResourceLoader());
        registerLoader("http", new HttpResourceLoader());

        registerSourceTypePattern("filesystem", "^file://");
        registerSourceTypePattern("filesystem", "^/");
        registerSourceTypePattern("http", "^https?://");
    }

    /**
     * Registers a new ResourceLoader for the given sourceType.
     */
    void registerLoader(string sourceType, ResourceLoader loader) {
        // set default source type if this is the first loader added
        // usually this will be "filesystem"
        if(loaders.length == 0) {
            defaultSourceType = sourceType;
        }
        loaders[sourceType] = loader;
    }

    /**
     * Registers a pattern for automatic source type detection.
     */
    void registerSourceTypePattern(string sourceType, string pattern) {
        sourceTypePatterns[pattern] = sourceType;
    }

    /**
     * Loads a resource.
     *
     * Parameters:
     *
     *  source = The source string. If sourceType is Autodetect, this will
     *           be tried to match against all registered sourceTypePatterns.
     *  name   = The name of the new resource.
     *  sourceType = The source type of this resource. Determines which
     *               resource loader is being used.
     */
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
                // writeln("Could not Auto-Detect SourceType for " ~ source);
                // writeln("  using default SourceType " ~ defaultSourceType);
                sourceType = defaultSourceType;
            } else {
                // writeln("Auto-Detect SourceType: " ~ sourceType);
                // writeln("  for " ~ source);
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