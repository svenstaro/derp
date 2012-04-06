import derp.all;

import std.stdio;

int main(string[] args) {
    /*
    ResourceManager resourceManager = new ResourceManager();
    Resource resource = resourceManager.load(args[1]);
    writeln("Resource name:        " ~ resource.name);
    writeln("Resource source type: " ~ resource.sourceType);
    */

    Node scene = new Node("Root");
    Node camNode = new Node("Camera", scene);
    Node entityNode = scene.createChildNode("Entity");

    writeln(entityNode.path);
    entityNode.setParent(camNode);
    writeln(entityNode.path);
    writeln(entityNode.rootNode.name);
    entityNode.setParent(null);
    writeln(entityNode.path);

    return 0;
}
