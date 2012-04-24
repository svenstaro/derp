import derp.all;
import std.stdio;
import std.string;

class BytesGenerator : ResourceGenerator {
    byte[] generate(ResourceSettings settings) {
        return new byte[settings.get!int("length")];
    }
}

void main() {
    ResourceManager manager = new ResourceManager();
    manager.softLimit = 100;

    BytesGenerator gen = new BytesGenerator();
    manager.registerLoader("bytesGenerator", gen);

    Resource r60 = manager.loadT!Resource(new ResourceSettings("length", 60), gen, "r60");
    Resource r20 = manager.loadT!Resource(new ResourceSettings("length", 20), gen, "r20");
    r60.required = false;

    // Up to now we had 80 bytes loaded, but the 60 byte resource is not needed
    // anymore. With 80+40 bytes we'd exceed the soft limit of 100, so the r60
    // should be free()'d
    Resource r40 = manager.loadT!Resource(new ResourceSettings("length", 40), gen, "r40");
    assert(r60.data.length == 0, format("The soft limit was exceeded to %s.", manager.totalMemory));

    manager.hardLimit = 200;
    // if everything went well, we now have 20 + 40 = 60 bytes allocated. Thus generating
    // 140 more should be ok, but 141 should break it
    try {
        Resource r141 = manager.loadT!Resource(new ResourceSettings("length", 141), gen, "r141");
        assert(false, "The hard limit was exceeded without an exception.");
    } catch(Exception e) {
        assert(e.msg == "Loading a resource exceeded memory hard limit of 200 by 1 bytes.", "Wrong exception triggered for exceeded hard limit: " ~ e.msg);
    }
}
