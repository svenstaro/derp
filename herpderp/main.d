import derp.all;

import std.stdio;
import std.random;
import std.format;
import std.string;

import derelict.opengl3.gl3;

int main(string[] args) {
    // Create the window
    Window window = new Window("Hello World", 800, 600, Window.Mode.Windowed, true, Window.ViewportType.Viewport);
    window.backgroundColor = Color.Black;

    // Load texture
    ResourceManager resourceManager = new ResourceManager();
    Texture texture = resourceManager.loadT!Texture(new UrlString("data/icon.png"));
    Texture cube = resourceManager.loadT!Texture(new UrlString("data/cube.png"));

    // Load font
    Font font = resourceManager.loadT!Font(new UrlString("data/fonts/dejavu/DejaVuSans.ttf"));
    font.pointSize = 30;

    // Create scene graph
    Node rootNode = new Node("rootNode");
    Node camNode = new Node("camNode", rootNode);
    Node spriteNode = new Node("spriteNode", rootNode);
    Node fontNode = new Node("fontNode", rootNode);
    Node polyNode = new Node("polyNode", rootNode);
    Node meshNode = new Node("meshNode", rootNode);

    // Create sprite
    SpriteComponent sprite = new SpriteComponent("Sprite", texture);
    spriteNode.attachComponent(sprite);
    sprite.smooth = true;
    // sprite.subRect = Rect(0.4, 0.4, 0.2, 0.2);

    spriteNode.position = Vector3(400, 300, 0);

    // Setup view
    CameraComponent cam = new CameraComponent("camera1", degrees(60), 3.0/4.0);
    cam.nearClipDistance = 1;
    cam.farClipDistance = 20;
    // cam.projectionMode = CameraComponent.ProjectionMode.Perspective;
    window.viewports[0].currentCamera = cam;
    //cam.orthographicBounds = Rect(0, 0, 800, 600);
    camNode.position = Vector3(0, 0, -2);
    //camNode.lookAt(Vector3(0, 0, 0));
    camNode.attachComponent(cam);

    // Headline
    TextComponent text = new TextComponent("headline", "Derp is awesome!", font);
    text.color = Color.Green;
    fontNode.attachComponent(text);
    fontNode.position = Vector3(400, 100, 0);

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
    polyNode.position = Vector3(700, 500, 0);
    polyNode.scale = Vector3(0.2, 0.2, 0.2);

    MeshData data = new MeshData();
    // front
    data.addQuad(
            new Vertex(Vector3(+1, -1, -1), Vector3(0, 0, -1), Vector2(0/5.0, 1)),
            new Vertex(Vector3(+1, +1, -1), Vector3(0, 0, -1), Vector2(1/5.0, 1)),
            new Vertex(Vector3(-1, +1, -1), Vector3(0, 0, -1), Vector2(1/5.0, 0)),
            new Vertex(Vector3(-1, -1, -1), Vector3(0, 0, -1), Vector2(0/5.0, 0)));
    // right
    data.addQuad(
            new Vertex(Vector3(+1, +1, -1), Vector3(0,  1, 0), Vector2(1/5.0, 1)),
            new Vertex(Vector3(+1, +1, +1), Vector3(0,  1, 0), Vector2(2/5.0, 1)),
            new Vertex(Vector3(-1, +1, +1), Vector3(0,  1, 0), Vector2(2/5.0, 0)),
            new Vertex(Vector3(-1, +1, -1), Vector3(0,  1, 0), Vector2(1/5.0, 0)));
    // back
    data.addQuad(
            new Vertex(Vector3(+1, +1, +1), Vector3(0, 0,  1), Vector2(2/5.0, 1)),
            new Vertex(Vector3(+1, -1, +1), Vector3(0, 0,  1), Vector2(3/5.0, 1)),
            new Vertex(Vector3(-1, -1, +1), Vector3(0, 0,  1), Vector2(3/5.0, 0)),
            new Vertex(Vector3(-1, +1, +1), Vector3(0, 0,  1), Vector2(2/5.0, 0)));
    // left
    data.addQuad(
            new Vertex(Vector3(-1, -1, -1), Vector3(0, -1, 0), Vector2(3/5.0, 1)),
            new Vertex(Vector3(-1, -1, +1), Vector3(0, -1, 0), Vector2(4/5.0, 1)),
            new Vertex(Vector3(+1, -1, +1), Vector3(0, -1, 0), Vector2(4/5.0, 0)),
            new Vertex(Vector3(+1, -1, -1), Vector3(0, -1, 0), Vector2(3/5.0, 0)));
    // bottom
    data.addQuad(
            new Vertex(Vector3(-1, +1, -1), Vector3(-1, 0, 0), Vector2(4/5.0, 0)),
            new Vertex(Vector3(-1, +1, +1), Vector3(-1, 0, 0), Vector2(5/5.0, 0)),
            new Vertex(Vector3(-1, -1, +1), Vector3(-1, 0, 0), Vector2(5/5.0, 1)),
            new Vertex(Vector3(-1, -1, -1), Vector3(-1, 0, 0), Vector2(4/5.0, 1)));
    // top
    data.addQuad(
            new Vertex(Vector3(+1, -1, -1), Vector3( 1, 0, 0), Vector2(4/5.0, 0)),
            new Vertex(Vector3(+1, -1, +1), Vector3( 1, 0, 0), Vector2(5/5.0, 0)),
            new Vertex(Vector3(+1, +1, +1), Vector3( 1, 0, 0), Vector2(5/5.0, 1)),
            new Vertex(Vector3(+1, +1, -1), Vector3( 1, 0, 0), Vector2(4/5.0, 1)));

    Material material = new Material();
    material.texture = cube;
    MeshComponent mesh = new MeshComponent("mesh-1", data, material);
    meshNode.attachComponent(mesh);

    // Example main loop
    float x = 0;
    int i = 0;
    while(window.isOpen) {
        i++;
        x += 0.05;
        spriteNode.rotation = degrees(- i * 0.5);
        sprite.scale = 0.1 * sin(i * 0.05) + 1;

        //fontNode.orientation = Quaternion.yrotation(x);
        // fontNode.rotation = degrees(i);
        // fontNode.rotation = degrees(sin(i * 0.05) * 10);

        meshNode.orientation = Quaternion.identity;
        meshNode.rotate(degrees(i * 0.5), Vector3(1, 1, 1), TransformSpace.Parent);
        meshNode.rotate(degrees(i * 0.3), Vector3(0, 1, 0), TransformSpace.Parent);
        meshNode.rotate(degrees(i * 0.2), Vector3(0, 1, 1), TransformSpace.Parent);
        meshNode.position = Vector3(0, 0, sin(i * 0.01) * 0.5 - 1);
        // camNode.rotate(degrees(i * 0.01), Vector3(0,1,0), TransformSpace.Parent);
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
