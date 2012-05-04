import derp.all;

import std.stdio;
import std.random;

int main(string[] args) {
    // Create the window
    Window window = new Window("Hello World", 800, 600, Window.Mode.Windowed);
    window.backgroundColor = Color.Black;

    // Load texture
    ResourceManager resourceManager = new ResourceManager();
    Texture texture = resourceManager.loadT!Texture(new UrlString("data/icon.png"));

    // Create scene graph
    Node rootNode = new Node("rootNode");
    Node camNode = new Node("camNode", rootNode);
    Node spriteNode = new Node("spriteNode", rootNode);

    // Create sprite
    SpriteComponent sprite = new SpriteComponent("Sprite", texture);
    spriteNode.attachComponent(sprite);
    sprite.smooth = false;

    // Setup view
    CameraComponent cam = window.viewports[0].currentCamera;
    cam.projectionMode = CameraComponent.ProjectionMode.Orthographic;
    cam.orthographicBounds = Rect(-0.5, -1, 1.5, 1.5);
    camNode.attachComponent(cam);

    // Example main loop
    float x = 0;
    while(window.isOpen()) {
        x += 0.05;
        //camNode.position = Vector3(sin(x), 0, 0);

        window.update();
        window.clear();
        window.render();
        window.display();
    }
    window.close();
    return 0;
}
