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

    // Load font
    Font font = resourceManager.loadT!Font(new UrlString("data/fonts/dejavu/DejaVuSans.ttf"));
    font.pointSize = 30;

    // Create scene graph
    Node rootNode = new Node("rootNode");
    Node camNode = new Node("camNode", rootNode);
    Node spriteNode = new Node("spriteNode", rootNode);
    Node fontNode = new Node("fontNode", rootNode);
    Node polyNode = new Node("polyNode", rootNode);

    // Create sprite
    SpriteComponent sprite = new SpriteComponent("Sprite", texture);
    spriteNode.attachComponent(sprite);
    sprite.smooth = true;
    // sprite.subRect = Rect(0.4, 0.4, 0.2, 0.2);

    spriteNode.position = Vector3(400, 300, 0);

    // Setup view
    CameraComponent cam = window.viewports[0].currentCamera;
    cam.projectionMode = CameraComponent.ProjectionMode.Orthographic;
    cam.orthographicBounds = Rect(0, 0, 800, 600);
    //camNode.translate(Vector3(0,0, 10));
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
