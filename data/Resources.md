# Derp Resource System

## Classes and Interfaces

- ResourceManager
- ResourceSource (Interface)
    - UrlString (default, constructed from string, casts to string)
    - ResourceSettings [map of settings]
- ResouceLoader (Interface)
    - FileSystemLoader
    - HttpLoader
    - ResourceGenerator
- Resource (Interface)
    - Texture
    - BinaryFile
    - Sound
    - Mesh
    - AssimpScene (redirects to other Resources)

## Creating a Resource

1. ResourceManager determines a Loader from the ResourceSource
2. If not specified, ResourceManager determines Type by ResourceSource URL or by loading raw data and analysing it
3. If the data is already loaded (in step 2), the Resource is created with that data
4. Otherwise the Resource is created with Loader and URL parameters, to load when required

The resource manager's interface for creating and loading resources:

        // ResourceManager.createUnstored(); ResourceManager.store()
        Resource ResourceManager.create(type, source, name = Autodetect, loader = Autodetect);

        // new Resource();
        Resource ResourceManager.createUnstored(type, source, name = Autodetect, loader = Autodetect);
        
        // ResourceManager.create(); Resource.load();
        // -> Resource.load will call ResourceManager.store() if it is not yet stored
        Resource ResourceManager.load(type, source, name = Autodetect, loader = Autodetect); 


        // Returns a stored resource
        Resource ResourceManager.get(name);

        // Stores, may call Resource.autodetectName(), which may throw exception 
        // if not loaded and not able to recognize from ResourceSources.
        // see "Resource Name Generation"
        Resource ResourceManager.store(resource, name = Autodetect); 

For each of the above calls, there is a casting shortcut, e.g.:

        Type ResourceManager.get(Type t)(name);
        // equivalent to 
        // cast(Type) ResourceManager.get(Type, name);
        // example:
        auto r = resourceManager.get!Texture("backgroundImage");

Some basic loading calls:

        // default call, automatic cast and automatic UrlString generation (from string)
        Texture a = resourceManager.load!Texture("path/to/file.png");

        // automatic cast, manual UrlString creation
        Texture b = resourceManager.load!Texture(UrlString("path/to/file.png"));
        
        // manual cast, manual UrlString creation
        Texture c = cast(Texture) resourceManager.load(Texture, UrlString("path/to/file.png"));

        // manual cast, automatic UrlString creation
        Texture d = cast(Texture) resourceManager.load(Texture, "path/to/file.png");
        

### Generated resource

For procedural content generation, the ResourceLoader is the generator, the ResourceSource keeps a map of settings for the loader:

        // automatic cast, automatic ResourceSource creation (because 
        ResourceSettings noiseSettings("width", 128, "height", 128);
        noiseSettings["foo"] = "bar";        // array access
        noiseSettings.set("bar", "baz");     // set method
        noiseSettings.type = Noise.Voronoi;  // opDispatch overwritten
        Texture e = resourceManager.load!Texture(noiseGenerator, noiseSettings);

## Automatic Loader detection by ResourceSource

The UrlString class registers regular expression patterns in a static map, and matches the URL against these. If no pattern matched, the default loader of the resource manager (usually a filesystem loader) is used. If the ResourceSource is an instance of ResourceSettings, it throws an error when trying to autodetect its type, except if the "type" member is set to the correct classinfo object.

## Types of Loaders

### The FileSystemLoader

The FileSystemLoader loads the file from a MergedFileSystem (multiple search paths). A sub-filesystem can also be a zipfile (which is loaded lazily and freed after loading (**TODO**)).

### The HttpLoader

Loads the resource from a http(s) stream.

### Custom loaders

By inheriting the interface `ResourceLoader`, one can create additional loaders for custom data sources, if required.

## Using a Resource

1. The resource class knows when it requires its data. 
2. If not already loaded, it uses the ResourceLoader and ResourceSource to let itself load.
3. It caches its data and data size, so the ResourceManager can request it to be freed when the space is required (see *Caching*).
4. When it is not needed anymore, it flags itself as unrequired.

## Resource Name Generation

If no name is specified for the resource, one is generated. The Resource can give itself a name when loaded, e.g. after reading its name from the binary data (useful for model names in ASSIMP resources etc.). If the name is required before loading the data (e.g. when create()ing it, but not load()ing it, it could generate a name from the ResourceSource. Otherwise the Resource class should throw an Exception.

## Asynchronous Loading of single resources or resource groups

1. The loading process can be started asynchronously.
2. The resources have to be created before loading them.
3. When progress is made, the resource/group triggers a callback given to the loading method.
4. The status update contains the total progress (in percent). This may be inaccurate in cases where the resource cannot determine its loaded size before the loading is finished, e.g. when loading from streams. But usually the ResourceLoader should be able to determine the size without loading the data.

## Caching

The resource loader holds all resources in memory, in a map, ordered by resource name. When a new resource is being loaded, but the soft limit is exceeded, the resource loader looks for the smallest unrequired resource to free (*throw away*). If there are no more unrequired resources, but there is not enough space for the (optional) hard limit, it throws an exception.

## Resource Groups

A resource group can apply loading (caching) and unloading (flagging as unrequired) on all its resources
- Useful for level-specific resources etc.
- A resource does not need a resource group
- The resource manager holds all resource groups, so they can be accessed by name (but they do not need to be, e.g. a level class can also hold a pointer to its own resource group).
