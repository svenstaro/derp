import derp.all;

import std.stdio;
import std.random;
import std.format;
import std.string;

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

    sprite.size = 100;
    spriteNode.position = Vector3(400, 300, 0);

    // Setup view
    CameraComponent cam = window.viewports[0].currentCamera;
    cam.projectionMode = CameraComponent.ProjectionMode.Orthographic;
    cam.orthographicBounds = Rect(0, 0, 800, 600);
    camNode.attachComponent(cam);

    // Example main loop
    float x = 0;
    int i = 0;
    while(window.isOpen()) {
        i++;
        x += 0.05;
        spriteNode.rotation = degrees(- x * 10);
        sprite.scale = 0.1 * sin(4 * x) + 1;
        
        camNode.position = Vector3(sin(x), cos(x), 0) * -100;

        window.update();
        window.clear();
        window.render();
        window.display();

        // Uncomment the following line to save the frames. Use
        //  $ cd /tmp/scrot/ && convert -resize 400x300 -delay 4 *.png animation.gif
        // to make an animated GIF from it. Make sure the directory /tmp/scrot/
        // exists before running the application.

        // window.saveScreenshot(format("/tmp/scrot/frame-%04s.png", i));
    }
    window.close();
    return 0;
}
