import derp.all;

import std.stdio;
import std.random;
import std.format;
import std.string;

import derelict.opengl3.gl3;
import derelict.assimp.assimp;

int main(string[] args) {
    // Create the window
    Window window = new Window("Hello World", 800, 600, Window.Mode.Windowed, true, Window.ViewportType.Viewport);
    window.backgroundColor = Color.Background;

    // Load texture
    ResourceManager resourceManager = new ResourceManager();
    Texture texture = resourceManager.loadT!Texture(new UrlString("data/icon.png"));
    Texture cube = resourceManager.loadT!Texture(new UrlString("data/checkerboard.png"));

    Scene scene = resourceManager.loadT!Scene(new UrlString("data/teamonkey.dae"));
    scene.initialize();

    // Load font
    Font font = resourceManager.loadT!Font(new UrlString("data/fonts/dejavu/DejaVuSans.ttf"));
    font.pointSize = 30;

    // Create scene graph
    Node rootNode = new Node("rootNode");
    Node camNode = new Node("camNode", rootNode);
    Node meshNode = new Node("meshNode", rootNode);
    // 2D stuff
    Node spritePlane = new Node("2DPlane", rootNode);
    Node spriteNode = new Node("spriteNode", spritePlane);
    Node fontNode = new Node("fontNode", spritePlane);
    Node polyNode = new Node("polyNode", spritePlane);

    spritePlane.scale = 1 / 100.0; //pixels per unit
    spritePlane.position = Vector3(2, 0, 0);

    // Create sprite
    SpriteComponent sprite = new SpriteComponent("Sprite", texture);
    spriteNode.attachComponent(sprite);
    sprite.smooth = true;
    // sprite.subRect = Rect(0.4, 0.4, 0.2, 0.2);

    // spriteNode.position = Vector3(400, 300, 0);

    // Setup view
    Viewport v = window.viewports[0];
    writeln(v.aspectRatio);
    CameraComponent cam = new CameraComponent("camera1", degrees(60), v.aspectRatio);
    cam.nearClipDistance = 1;
    cam.farClipDistance = 20;
    // cam.projectionMode = CameraComponent.ProjectionMode.Perspective;
    v.currentCamera = cam;
    //cam.orthographicBounds = Rect(0, 0, 800, 600);
    camNode.position = Vector3(0, 0, -3);
    //camNode.orientation = Quaternion.xrotation(degrees(30).radians);
    //camNode.lookAt(Vector3(0, 0, 0));
    camNode.attachComponent(cam);

    //setCullMode(CullMode.None);

    // Headline
    TextComponent text = new TextComponent("headline", "Derp is awesome!", font);
    text.color = Color.Green;
    fontNode.attachComponent(text);
    //fontNode.position = Vector3(400, 100, 0);

    PolygonComponent poly = new PolygonComponent("test-1");
    poly.color = Color(1, 0, 0, 0.8);
    poly.addPoint(Vector2(   0, -100));
    poly.addPoint(Vector2(  30, -170));
    poly.addPoint(Vector2( 100, -200));
    poly.addPoint(Vector2( 170, -170));
    poly.addPoint(Vector2( 200, -100));
    poly.addPoint(Vector2(   0,  150));
    poly.addPoint(Vector2(-200, -100));
    poly.addPoint(Vector2(-170, -170));
    poly.addPoint(Vector2(-100, -200));
    poly.addPoint(Vector2(- 30, -170));
    poly.addPoint(Vector2(   0, -100));

    polyNode.attachComponent(poly);
    polyNode.position = Vector3(0, 0, 1);
    //polyNode.scale = Vector3(0.2, 0.2, 0.2);

    Material material = new Material();
    material.texture = cube;
    MeshComponent mesh = new MeshComponent("mesh-1", scene.getMesh(0), material);
    meshNode.attachComponent(mesh);

    // Example main loop
    while(window.isOpen) {
        double dt = window.tick();

        writefln("%s - %s", window.currentFPS, window.averageFPS);

        sprite.scale = 0.1 * sin(window.lifetime * 2) + 1;
        meshNode.position = Vector3(sin(window.lifetime), 0, 0);
        spritePlane.orientation = Quaternion.yrotation(degrees(window.lifetime * 100).radians);

        meshNode.orientation = Quaternion.yrotation(degrees(window.lifetime * 0.2).radians);

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
