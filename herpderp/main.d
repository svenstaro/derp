import derp.all;

import std.stdio;
import std.random;
import std.format;
import std.string;

int main(string[] args) {
    // Create the window
    Window window = new Window("Hello World", 800, 600, Window.Mode.Windowed);
    window.backgroundColor = Color(0.5, 0.5, 0.5);
    window.backgroundColor = Color.Background;

    // Load texture
    ResourceManager resourceManager = new ResourceManager();
    Texture texture = resourceManager.loadT!Texture(new UrlString("data/icon.png"));

    // Load font
    Font font = resourceManager.loadT!Font(new UrlString("data/fonts/dejavu/DejaVuSans.ttf"));
    font.pointSize = 20;

    // Create scene graph
    Node rootNode = new Node("rootNode");
    Node camNode = new Node("camNode", rootNode);
    Node spriteNode = new Node("spriteNode", rootNode);
    Node fontNode = new Node("fontNode", rootNode);
    Node meshNode = new Node("meshNode", rootNode);

    // Create sprite
    SpriteComponent sprite = new SpriteComponent("Sprite", texture);
    spriteNode.attachComponent(sprite);
    sprite.smooth = true;
    sprite.color = Color(0.1, 0.1, 0.1, 0);
    sprite.colorBlendMode = SpriteComponent.BlendMode.Additive;
    //sprite.subRect = Rect(0.4, 0.4, 0.2, 0.2);

    spriteNode.position = Vector3(400, 300, 0);

    // Setup view
    CameraComponent cam = window.viewports[0].currentCamera;
    cam.projectionMode = CameraComponent.ProjectionMode.Orthographic;
    cam.orthographicBounds = Rect(0, 0, 800, 600);
    camNode.attachComponent(cam);

    // Headline
    TextComponent text = new TextComponent("headline", "Derp is awesome!", font);
    text.color = Color(1, 1, 0.6);
    fontNode.attachComponent(text);
    fontNode.position = Vector3(400, 100, 0);
    fontNode.rotation = degrees(90);

    MeshComponent mesh = new MeshComponent("testmesh");
    //auto v = mesh.vertices;
    VertexData[] v;
    float radius = 100;
    for(int i = 0; i < 16; i++) {
        float a1 = i / 16.0 * 2 * PI;
        float a2 = (i + 1) / 16.0 * 2 * PI;

        float w = i / 15.0;
        float z = i / 16.0 - 0.5;

        v ~= VertexData(radius * sin(a1), radius * cos(a1), z, w, w, w, 2, 0, 0);
        v ~= VertexData(radius * sin(a2), radius * cos(a2), z, w, w, w, 2, 0, 0);
        v ~= VertexData(0, 0, z, w, w, w, 2, 0, 0);
    }
    mesh.vertices = v;
    mesh.texture = texture;
    meshNode.attachComponent(mesh);
    meshNode.position = Vector3(400, 400, 0);

    // Example main loop
    float x = 0;
    int i = 0;
    while(window.isOpen()) {
        i++;
        x += 0.05;
        // spriteNode.rotation = degrees(- i * 0.5);
        sprite.scale = 0.1 * abs(sin(i * 0.05)) + 1;

        meshNode.orientation = Quaternion.zrotation(degrees(i * 2).radians);
        
        fontNode.rotation = degrees(sin(i * 0.05) * 10);
    
        
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
