import derp.all;

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
    Window w = new Window("Hello World", 800, 600, Window.Mode.Windowed);

    // Load texture
    ResourceManager mgr = new ResourceManager();
    Resource image = mgr.load("data/icon.png");
    Texture tex = new Texture();
    tex.loadFromMemory(cast(byte[])image.bytes);

    Sprite s = new Sprite(tex);

    w.backgroundColor = Color.Gray;

    float x = 0;
    while(w.isOpen()) {
        x += 0.03;

        Vector3 camPos = Vector3(
            sin(x) * 2,
            cos(x) * 2,
            - 4
            );

        Matrix4 projection = orthographicProjection(-1, 1, -1, 1);
        Matrix4 modelView = Matrix4(
            1, 0, 0, 0,
            0, 1, 0, 0,
            0, 0, 1, 0,
            - camPos.x, - camPos.y, - camPos.z, 1
            );
        // ProjectionMatrix mat = ProjectionMatrix.look_at(camPos, Vector3(0, 0, 0), Vector3(0, 1, 0));
        ShaderProgram.defaultPipeline.setMvpMatrix(modelView * projection);

        w.update();
        w.clear();
        s.render();
        glCheck();
        w.display();
    }
    w.close();

    return 0;
}
