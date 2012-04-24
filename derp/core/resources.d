/**
 * Module for resource loading from different sources.
 *
 * Todo: Merge with derp.fs and Resource class.
 */

module derp.core.resources;

import std.stdio;
import std.regex;
import std.file;
import std.path;
import std.string;
import std.conv;
import std.net.curl;
import std.traits;
import std.algorithm;

import derp.core.fs;

alias ClassInfo ResourceType;

abstract class ResourceSource {
    ResourceType autodetectType() {
        return null;
    }

    string autodetectName() {
        return "";
    }
}

class UrlString : ResourceSource {
    string url;
    this(string url) {
        this.url = url;
    }

    void opCast(T = string)(out string s) {
        s = this.url;
    }

    string toString() {
        return this.url;
    }

    string autodetectName() {
        return baseName(stripExtension(this.url));
    }
}

class ResourceSettings : ResourceSource {
    string[string] settings;
    this(S...)(S args) {
        assert(args.length % 2 == 0, "The arguments have to be keys and values, e.g. ('key1', 'value1', 'key2', 'value2', ...).");

        string key = "";
        foreach(arg; args) { // int i = 0; i < args.length; i += 2) {
            if(key == "") {
                assert(is(typeof(arg) == string), "Keys must be strings.");
                key = to!string(arg);
            } else {
                settings[key] = to!string(arg);
                key = "";
            }
        }
    }

    void set(T)(string name, T value) {
        this.settings[name] = to!string(value);
    }

    T get(T = string)(string name) {
        if(name in this.settings) {
            string value = this.settings[name];

            static if(isIntegral!T) {
                return parse!T(value);
            } else
                return to!T(value);
        } else {
            static if(isIntegral!T)
                return 0;
            else return null;
        }
    }

    void opDispatch(string name, T)(T value) {
        this.set(name, value);
        // this.settings[name] = to!string(value);
    }

    auto opDispatch(string name)() {
        if(name in this.settings)
            return mixin("this.settings[\""~ name ~"\"]"); // required for auto-type
        return null;
        //return this.get!string(name);
    }

    string toString() {
        string s = "ResourceSettings [";
        foreach(k, v; this.settings)
            s ~= format("%s = %s, ", k, v);
        return s;
    }
}

/**
 * Holds resouce data after loading.
 */
class Resource {
private:
    string _sourceType;  /// The type of the source used to load this resource.
    string _name;        /// The name of this resource.
    ResourceLoader _loader; /// The loader used/selected for this resources.
    ResourceSource _source; /// The source information for this resource.
    byte[] _data;        /// The actual resource data.
    bool _required;

public:
    @property bool required() {
        return this._required;
    }

    @property void required(bool required) {
        bool madeRequired = required && !this._required;
        this._required = required;
        if(madeRequired && !loaded) {
            this.load();
        }
    }

    @property string name() {
        return this._name;
    }

    @property void name(string name) {
        this._name = name;
    }

    @property ResourceSource source() {
        return this._source;
    }

    @property void source(ResourceSource source) {
        assert(!this.loaded, "Can only set resource source if resource is not loaded. Call free() before setting a new source.");
        this._source = source;
    }

    @property void data(byte[] data) {
        this._data = data;
    }

    @property byte[] data() {
        return this._data;
    }

    @property ResourceLoader loader() {
        return this._loader;
    }

    @property void loader(ResourceLoader loader) {
        this._loader = loader;
    }

    void create(ResourceLoader loader, ResourceSource source, byte[] data = []) {
        this._loader = loader;
        this._source = source;
        this._data = data;
    }

    bool load() {
        return this._loader.loadInto(this);
    }

    void free() {
        this._required = false;
        this._data = [];
    }

    @property bool loaded() {
        return this._data.length > 0;
    }

    string autodetectName() {
        return "";
    }
}

class Script : Resource {
    @property string text() {
        return to!string(this.data);
    }
}

/**
 * Abstract class for custom resource loaders.
 */
abstract class ResourceLoader {
    ResourceManager manager;

    bool loadInto(Resource resource) {
        if(resource.loaded) return true;

        byte[] data;
        if(!loadRawData(resource.source, data)) {
            writefln("Failed to load resource %s.", resource.name);
            return false;
        }
        resource.data = data;
        this.manager.resourceSizeChanged(resource);
        return true;
    }

    /// Overwrite this to implement custom loading process.
    bool loadRawData(ResourceSource source, out byte[] data);

    /// Tries to determine the size of a resource (in bytes) before it has been loaded.
    /// This may not be possible in all cases, if so, 0 is returned.
    ulong size(ResourceSource source) {
        return 0;
    }

    ///
    bool matchesResourceSource(ResourceSource source) {
        return false;
    }
}

abstract class UrlResourceLoader : ResourceLoader {
    string[] urlPatterns;

    static string url(ResourceSource source) {
        return (cast(UrlString)source).url;
    }

    bool matchesResourceSource(ResourceSource source) {
        foreach(p; urlPatterns) {
            if(match(url(source), regex(p, "i"))) {
                return true;
            }
        }
        return false;
    }
}

abstract class ResourceGenerator : ResourceLoader {
}

/**
 * Loads a resource from a MergedFileSystem.
 */
class FilesystemResourceLoader : UrlResourceLoader {
    MergedFileSystem fileSystem; /// The MergedFileSystem to load resources from.

    /// Constructor
    this() {
        this.fileSystem = new MergedFileSystem();
        this.fileSystem.fileSystems ~= new FileSystem(""); // find files in current directory
    }

    bool loadRawData(ResourceSource source, out byte[] data) {
        data = cast(byte[])this.fileSystem.read(url(source));
        return true;
    }

    ulong size(ResourceSource source) {
        return this.fileSystem.getSize(url(source));
    }

    static string removeProtocol(string input) {
        return replace(input, regex("^file://", "i"), "");
    }
}

/**
 * Loads a resource from a remote server via HTTP.
 */
class HttpResourceLoader : UrlResourceLoader {
    bool loadRawData(ResourceSource source, out byte[] data) {
        data = cast(byte[])std.net.curl.get(url(source));
        return true;
    }

    static string removeProtocol(string input) {
        return replace(input, regex("^https?://", "i"), "");
    }
}

/**
 * Manages groups of resources.
 */
class ResourceGroup {
private:
    string _name;
    Resource[] _resources;
    ResourceManager _manager;

public:
    this(string name, ResourceManager manager) {
        this._name = name;
        this._manager = manager;
    }

    @property string name() {
        return this._name;
    }

    @property ResourceManager manager() {
        return this._manager;
    }

    void add(Resource resource) {
        if(!canFind(this._resources, resource))
            this._resources ~= resource;
    }

    void remove(Resource resource) {
        std.algorithm.remove(this._resources, countUntil(this._resources, resource));
    }

    void loadAll() {
        foreach(r; this._resources) {
            if(!r.load()) {
                writefln("Failed to load resource %s via group %s.", r.name, this.name);
            }
        }
    }

    void freeAll() {
        foreach(r; this._resources) {
            r.free();
        }
    }

    @property void required(bool required) {
        foreach(r; this._resources) {
            r.required = required;
        }
    }
}

/**
 * Loads and holds resources and registered resource loaders.
 */
class ResourceManager {
    ResourceLoader[string] loaders;         /// List of registered resource loaders.
    ResourceLoader defaultLoader = null;    /// Default loader, used if automatic detection fails.
    ResourceType[string] resourceTypes;     /// List of registered resource classes.
    ResourceGroup[string] resourceGroups;   /// List of all resource groups for this manager.
    Resource[string] resources;             /// List of created resources.

    /**
     * Constructor.
     */
    this() {
        registerLoader("filesystem", new FilesystemResourceLoader());
        registerLoader("http", new HttpResourceLoader());

        // registerResourceType!Texture;
        // registerResourceType!SoundBuffer;
    }

    ResourceGroup createGroup(string name) {
        if(name in this.resourceGroups) {
            throw new Exception("Cannot create group of name `" ~ name ~ "`, a group with this name already exists.");
        }

        ResourceGroup group = new ResourceGroup(name, this);
        this.resourceGroups[name] = group;
        return group;
    }

    /**
     * Registers a new ResourceLoader with the given name.
     */
    void registerLoader(string name, ResourceLoader loader) {
        // set default source type if this is the first loader added
        // usually this will be "filesystem"
        if(loaders.length == 0) {
            defaultLoader = loader;
        }
        loaders[name] = loader;
        loader.manager = this;
    }

    void registerResourceType(T)() {
        this.resourceTypes[T.classinfo.name] = T.classinfo;
    }

    ResourceLoader autodetectLoader(ResourceSource source) {
        foreach(l; loaders) {
            if(l.matchesResourceSource(source))
                return l;
        }
        return defaultLoader;
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
    /*Resource load(string source, string name = Autodetect, string sourceType = Autodetect) {
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
    }*/

    ResourceType autodetectType(ResourceSource source) {
        if(is(typeof(source) == UrlString)) {
            // try detecting type from the extension
            string ex = extension((cast(UrlString)source).url);
            // TODO
        }
        // TODO: Try determining type from loader (e.g. texture generators usually only generate textures)
        return null;
    }

    ResourceType autodetectType(byte[] data) {
        // TODO: implement some detection algorithms (e.g. file headers for different image formats like PNG, JPEG, ...)
        return null;
    }

    /**
     * Creates and stores a new resource object.
     */
    Resource create(ResourceType type, ResourceSource source, ResourceLoader loader = null, string name = "") {
        // first create
        Resource r = this.createUnstored(type, source, loader);

        // now store
        this.store(r, name);

        // and return
        return r;
    }

    /// ditto
    T createT(T: Resource)(ResourceSource source, ResourceLoader loader = null, string name = "") {
        return cast(T)create(T.classinfo, source, loader, name);
    }

    Resource createUnstored(ResourceType type, ResourceSource source, ResourceLoader loader = null) {
        // autodetect loader from source
        if(loader is null) {
            loader = autodetectLoader(source);
        }

        // autodetect type from source
        if(type is null) {
            type = autodetectType(source);
        }

        byte[] data;
        // autodetect type from binary data
        if(type is null) {
            bool success = loader.loadRawData(source, data);
            if(!success) {
                throw new Exception("Cannot load resource data for determining the type.");
            }
            type = autodetectType(data);
        }

        if(type is null) {
            throw new Exception("Cannot automatically detect resource type.");
        }

        Resource r = cast(Resource)type.create();
        r.loader = loader;
        r.source = source;
        if(data.length > 0) {
            r.data = data;
        }
        return r;
    }

    T createUnstoredT(T: Resource)(ResourceSource source, ResourceLoader loader = null) {
        return cast(T)this.createUnstored(T.classinfo, source, loader);
    }

    // ResourceManager.createUnstored(); Resource.load();
    // Resource.load() will make resource name detection by data possible
    Resource load(ResourceType type, ResourceSource source, ResourceLoader loader = null, string name = "") {
        Resource r = this.createUnstored(type, source, loader);
        r.load();
        this.store(r);
        return r;
    }

    /// ditto
    T loadT(T: Resource)(ResourceSource source, ResourceLoader loader = null, string name = "") {
        return cast(T)this.load(T.classinfo, source, loader, name);
    }

    // Returns a stored resource
    Resource get(string name) {
        if(name !in this.resources)
            return null;
        return this.resources[name];
    }

    T getT(T)(string name) {
        return cast(T)this.get(name);
    }

    void resourceSizeChanged(Resource resource) {
        // TODO: free memory when limits are reached
    }

    // Stores, may call Resource.autodetectName(), which may return an empty name.
    // Then it is tried to detect the name from the ResourceSource, which may
    // also return an empty name. In this case this method throws an exception.
    void store(Resource resource, string name = "") {
        // first, try and let the resource give itself a name
        if(name == "" && resource.loaded) {
            name = resource.autodetectName();
        }
        // if unsuccessful, try to give it a name from the source information (e.g. URL's basename)
        if(name == "") {
            name = resource.source.autodetectName();
        }
        // if no name could be found, throw error
        if(name == "") {
            throw new Exception(format("Could not automatically determine a name for the resource from `%s`.", resource.source));
        }
        resource.name = name;
        this.resources[name] = resource;
    }
}
