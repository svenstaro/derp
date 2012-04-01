import derp.all;

import std.stdio;

int main(string[] args) {
    ResourceManager resourceManager = new ResourceManager();

    Resource resource = resourceManager.load(args[1]);
    writeln("================================");
    writeln("Resource name:        " ~ resource.name);
    writeln("Resource source type: " ~ resource.sourceType);
    writeln("================================");
    writeln("HERE COMES CONTENT:");
    writeln("================================");
    writeln(resource.data);

    return 0;
}
