import derp.all;
import derp.graphics.camera;

import std.stdio;
import std.math;
import std.random;

import derelict.opengl3.gl3;
import derelict.glfw3.glfw3;
import gl3n.linalg;

Matrix4 orthographicProjection(float l, float r, float t, float b, float n = 0.01, float f = 1000000) {
    return Matrix4(
        2.0 / (r - l), 0, 0, - (r + l) / (r - l),
        0, 2.0 / (t - b), 0, - (t + b) / (t - b),
        0, 0, 2.0 / (n - f), - (n + f) / (n - f),
        0, 0, 0, 1
    );
}

int main(string[] args) {
    Window window = new Window("Hello World", 800, 600, Window.Mode.Windowed);
    window.backgroundColor = Color.Gray;
    
    // Load texture
    ResourceManager resourceManager = new ResourceManager();
    Resource image = resourceManager.load("data/icon.png");
    Texture texture = new Texture(image);

    SpriteComponent sprite = new SpriteComponent("Sprite", texture);

    CameraComponent cam = new CameraComponent("testCam", degrees(80), 1, 1, 1000);

    Node rootNode = new Node("rootNode");
    Node cameraNode = new Node("cameraNode", rootNode);
    Node spriteNode = new Node("spriteNode", rootNode);
    cameraNode.attachComponent(cam);
    spriteNode.attachComponent(sprite);
    
    float x = 0;
    while(window.isOpen()) {
        x += 0.03;

        Vector3 camPos = Vector3(
            sin(x) * 2,
            cos(x) * 2,
             20
            );

        Matrix4 projection = cam.projectionMatrix;//orthographicProjection(-1, 1, -1, 1);
        Matrix4 modelView = Matrix4(
            1, 0, 0, 0,
            0, 1, 0, 0,
            0, 0, 1, 0,
            - camPos.x, - camPos.y, - camPos.z, 1
            );
        // ProjectionMatrix mat = ProjectionMatrix.look_at(camPos, Vector3(0, 0, 0), Vector3(0, 1, 0));
        ShaderProgram.defaultPipeline.setMvpMatrix(modelView * projection);

        window.update();
        window.clear();
        writeln("...");
        cam.render(new Viewport());
        glCheck();
        window.display();
    }
    window.close();

    return 0;
}
