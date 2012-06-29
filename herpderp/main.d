import derp.all;

import std.stdio;
import std.random;
import std.format;
import std.string;

int main(string[] args) {
    // Create the window
    Window window = new Window("Hello World", 800, 600, Window.Mode.Windowed, true, Window.ViewportType.Viewport);
    window.backgroundColor = Color.Gray;

    // Load texture
    ResourceManager resourceManager = new ResourceManager();
    Texture texture = resourceManager.loadT!Texture(new UrlString("data/icon.png"));

    // Load font
    Font font = resourceManager.loadT!Font(new UrlString("data/fonts/dejavu/DejaVuSans.ttf"));
    font.pointSize = 30;

    // Create scene graph
    Node rootNode = new Node("rootNode");
    Node camNode = new Node("camNode", rootNode);
    Node spriteNode = new Node("spriteNode", rootNode);
    Node fontNode = new Node("fontNode", rootNode);
    Node meshNode = new Node("meshNode", rootNode);

    // Create sprite
    SpriteComponent sprite = new SpriteComponent("Sprite", texture);
   // spriteNode.attachComponent(sprite);
    sprite.smooth = true;
    //sprite.subRect = Rect(0.4, 0.4, 0.2, 0.2);

    spriteNode.position = Vector3(0, 0, 0);
    
    // Create cube
    MeshComponent mesh = makeCubeMesh(texture);
    meshNode.position = Vector3(0,0,0);
    meshNode.attachComponent(mesh);
    //meshNode.scale = Vector3(1,1,1);

    // Setup view
    CameraComponent cam = new CameraComponent("testCam");
    window.viewports[0].currentCamera = cam;
    //CameraComponent cam = window.viewports[0].currentCamera;
    //cam.projectionMode = CameraComponent.ProjectionMode.Orthographic;
    //cam.orthographicBounds = Rect(0, 0, 800, 600);
    camNode.attachComponent(cam);
    camNode.position = Vector3(0,0,-500);
    camNode.scale = Vector3(10,10,10);
    //camNode.lookAt(Vector3(0,0,0));

    // Headline
    //~ TextComponent text = new TextComponent("headline", "Derp is awesome!", font);
    //~ text.color = Color.Yellow;
    //~ fontNode.attachComponent(text);
    //~ fontNode.position = Vector3(300, 100, 0);

    // Example main loop
    float x = 0;
    int i = 0;
    while(window.isOpen()) {
        i++;
        x += 0.05;
        //spriteNode.rotation = degrees(- i * 0.5);
        //sprite.scale = 0.1 * sin(i * 0.05) + 1;
        
        //meshNode.rotation = degrees(- i * 0.5);
        
        //fontNode.rotation = degrees(i);

        //fontNode.rotation = degrees(sin(i * 0.05) * 10);

    
        
        //camNode.position = Vector3(sin(x), cos(x), 0) * -100;

        window.update();
        window.clear();
        window.render();
        window.display();

        // Uncomment the following line to save the frames. Use
        //  $ cd /tmp/scrot/ && convert -resize 400x300 -delay 4 *.png animation.gif
        // to make an animated GIF from it. Make sure the directory /tmp/scrot/
        // exists before running the application.

        //if(i <= 720)
        //    window.saveScreenshot(format("/tmp/scrot/frame-%04s.png", i));

        //if(i == 10) {
        //    window.saveScreenshot("frame-10.png");
        //}
    }
    window.close();
    return 0;
}
