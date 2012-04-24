import derp.all;

import std.stdio;
import std.random;

int main(string[] args) {
    //Create a Window
    Window window = new Window("Hello World", 800, 600, Window.Mode.Windowed);
    window.backgroundColor = Color.Black;

    // Load texture
    ResourceManager resourceManager = new ResourceManager();
    Texture texture = resourceManager.loadT!Texture(new UrlString("data/icon.png"));
    writeln("Loaded texture \"", texture.name, "\"");

    //Create SceneGraph
    Node rootNode = new Node("rootNode");
    Node cameraNode = new Node("cameraNode", rootNode);
    Node spriteNode = new Node("spriteNode", rootNode);

    //Create Components
    SpriteComponent sprite = new SpriteComponent("Sprite", texture);
    CameraComponent cam = new CameraComponent("testCam", degrees(60), window.width/window.height, 1, 1000);

    //Attach Components
    cameraNode.attachComponent(cam);
    spriteNode.attachComponent(sprite);

    // Set Render Target
    window.viewports[0].currentCamera = cam;
    window.viewports[0].bounds = Rect(Vector2(0, 0), window.size);

    //Render Demo Scene
    float x = 0;
    while(window.isOpen()) {
        x += 0.03;

        Vector3 camPos = Vector3(
            sin(x) * -2,
            cos(x) * -2,
             -20
            );

        cameraNode.position = camPos;

        window.update();
        window.clear();
        window.render();
        window.display();
    }
    window.close();
    return 0;
}
