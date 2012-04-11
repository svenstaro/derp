import derp.all;

import std.stdio;
import std.math;
import std.random;

import derelict.opengl3.gl3;
import derelict.glfw3.glfw3;
import gl3n.linalg;

static string fragmentSolid = "#version 120

varying vec4 fColor;


void main() {
    gl_FragColor = fColor;
    //gl_FragColor = vec4(1.0, 0.0, 0.0, 1.0);
}
";

static string standardVertex = "#version 120
uniform mat4 uModelViewProjectionMatrix;
attribute vec3 vVertex;
attribute vec2 vTexCoord;
attribute vec4 vColor;

varying vec4 fColor;
varying vec2 fTexCoord;

void main() {
    gl_Position = uModelViewProjectionMatrix * vec4(vVertex, 1.0);
    // gl_Position = vec4(vVertex.x, vVertex.y, 0.0, 1.0);
    // gl_TexCoord[0].st = vTexCoord;

    // fColor = vColor;
    fColor = vColor; // vec4(1.0, 0.0, 0.0, 1.0);
    fTexCoord = vTexCoord;
}
";

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

    Shader[] shaders;
    shaders ~= new Shader(standardVertex, Shader.Type.vertex);
    shaders ~= new Shader(fragmentSolid, Shader.Type.fragment);
    ShaderProgram defaultShaderProgram = new ShaderProgram(shaders);


    // Create vertex data (VBO)

    VertexBufferObject vbo = new VertexBufferObject(defaultShaderProgram);
    VertexData[] data;
    data ~= VertexData( 0.0,  0.8, 0, 1, 0, 0);
    data ~= VertexData( 0.8, -0.8, 0, 0, 1, 0);
    data ~= VertexData(-0.8, -0.8, 0, 0, 0, 1);
    vbo.setVertices(data);

    w.backgroundColor = Color.Background;
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
        defaultShaderProgram.setMvpMatrix(modelView * projection);

        w.update();
        w.clear();
        vbo.render();
        glCheck();
        w.display();
    }
    w.close();

    return 0;
}
