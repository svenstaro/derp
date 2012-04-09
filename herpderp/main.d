import derp.all;

import std.stdio;
import std.random;

import derelict.opengl3.gl3;
import derelict.glfw3.glfw3;
import gl3n.linalg;

static string fragmentTexture = "#version 120
uniform sampler2D Texture;
uniform vec2 _texCoord;

void main() {
    gl_FragColor = texture2D(Texture, vec2(_texCoord));
}
";

static string fragmentSolid = "#version 120
uniform vec4 _color;

void main() {
    gl_FragColor = _color;
}
";

static string standardVertex = "#version 120
uniform mat4 projectionMatrix;
uniform vec3 _vertex;
uniform vec2 _texCoord;

void main() {
    gl_Position = projectionMatrix * vec4(_vertex, 1.0);
    gl_TexCoord[0].st = _texCoord;
}
";

int main(string[] args) {
    Window w = new Window("Hello World", 800, 600, Window.Mode.Windowed);

    Shader[] shaders;
    shaders ~= new Shader(standardVertex, Shader.Type.vertex);
    shaders ~= new Shader(fragmentSolid, Shader.Type.fragment);
    ShaderProgram defaultShaderProgram = new ShaderProgram(shaders);

    VertexBufferObject vbo = new VertexBufferObject(defaultShaderProgram);

    VertexData[] data;
    data ~= VertexData(-5, -4, 0, 1, 0, 0);
    data ~= VertexData( 5, -4, 0, 0, 1, 0);
    data ~= VertexData( 0, 6,  0, 0, 0, 1);

    vbo.setVertices(data);

    writeln(&data);

    w.backgroundColor = Color.Background;
    while(w.isOpen()) {
        Vector3 camPos = Vector3(
            uniform(-10.0, 10.0),
            uniform(-10.0, 10.0),
            uniform(-10.0, 10.0)
            );
        ProjectionMatrix mat = ProjectionMatrix.look_at(camPos, Vector3(0, 0, 0), Vector3(0, 1, 0));
        defaultShaderProgram.setProjectionMatrix(mat);

        w.update();
        w.clear();
        vbo.render();
        glCheck();
        w.display();
    }
    w.close();

    return 0;
}
