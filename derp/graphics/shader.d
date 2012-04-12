module derp.graphics.shader;

import std.string;
import std.conv;

import derelict.opengl3.gl3;
import derelict.glfw3.glfw3;
import gl3n.linalg;

import derp.core.geo;
import derp.graphics.util;
import derp.graphics.draw;
import derp.graphics.view;
import derp.graphics.texture;

import std.array;

class Shader {
    enum Type {
        vertex      = GL_VERTEX_SHADER,
        fragment    = GL_FRAGMENT_SHADER,
        geometry    = GL_GEOMETRY_SHADER
    }

    string source;
    Type type;
    int handle;

    this(string source, Type type) {
        this.source = source;
        this.type = type;
        create();
    }

    delete(void* shader) {
        (cast(Shader)shader).destroy();
    }

    void create() {
        this.handle = glCreateShader(this.type);
        // writefln("Created Shader %s", this.handle);
        const char* source = this.source.toStringz();
        glShaderSource(this.handle, 1, &source, null);
        glCheck();
        glCompileShader(this.handle);
        glCheck();

        string info = infoLog;
        if(info != "") writeln(info);
        assert(info == "", "failed to compile shader.");
    }

    @property string infoLog() {
        int len;
        glGetShaderiv(handle, GL_INFO_LOG_LENGTH , &len);
        if (len > 1) {
            char[] msg = new char[len];
            glGetShaderInfoLog(handle, len, null, cast(char*) msg);
            return cast(string)msg;
        }
        return "";
    }

    void destroy() {
        glDeleteShader(this.handle);
        glCheck();
    }
}

import std.stdio;

/**
 *  This is a shading program, consisting of multiple shaders
 *  (usually a vertex and a fragment shader).
 */
class ShaderProgram {
    int handle;

    this(Shader[] shaders) {
        this.create(shaders);
    }

    delete(void* shaderProgram) {
        (cast(ShaderProgram)shaderProgram).destroy();
    }

    @property string infoLog() {
        int len;
        glGetProgramiv(handle, GL_INFO_LOG_LENGTH , &len);
        if (len > 1) {
            char[] msg = new char[len];
            glGetProgramInfoLog(handle, len, null, cast(char*) msg);
            return cast(string)msg;
        }
        return "";
    }

    void create(Shader[] shaders) {
        this.handle = glCreateProgram();
        assert(glIsProgram(this.handle), "Failed to create ShaderProgram.");

        // attach
        foreach(s; shaders) {
            glAttachShader(this.handle, s.handle);
            glCheck();
        }

        // link
        glBindAttribLocation(handle, 0, "vVertex");
        glBindAttribLocation(handle, 1, "vColor");
        glBindAttribLocation(handle, 2, "vTexCoord");
        glCheck();


        glLinkProgram(this.handle);
        glCheck();

        int linkSuccess;
        glGetProgramiv(this.handle, GL_LINK_STATUS, &linkSuccess);
        assert(linkSuccess == GL_TRUE, "Linker error.");

        // check here
        string info = infoLog;
        if(info != "") writeln(info);
        assert(info == "", "Failed to link program.");

        int validateSuccess;
        glValidateProgram(handle);
        glGetProgramiv(handle, GL_VALIDATE_STATUS, &validateSuccess);
        assert(validateSuccess == GL_TRUE, "Validation error.");

        glCheck();

        // detach
        foreach(s; shaders) {
            glDetachShader(this.handle, s.handle);
            glCheck();
        }
    }

    void destroy() {
        glDeleteProgram(this.handle);
        glCheck();
    }

    void attach() {
        glUseProgram(this.handle);
        glCheck();
    }

    void detach() {
        glUseProgram(0);
        glCheck();
    }

    void sendUniformMat4(int position, Matrix4 mat) {
        attach();
        glUniformMatrix4fv(position, 1, false, mat.value_ptr());
        detach();
        glCheck();
    }

    void sendUniformVec2(int position, Vector2 v) {
        attach();
        glUniform2fv(position, 1, v.value_ptr());
        detach();
        glCheck();
    }

    int getUniformLocation(string name) {
        const char* n = name.toStringz();
        int x = glGetUniformLocation(this.handle, &n[0]);
        glCheck();
        return x;
    }

    int getAttribLocation(string name) {
        const char* n = name.toStringz();
        int x = glGetAttribLocation(this.handle, &n[0]);
        glCheck();
        return x;
    }

    void sendUniformFloat(int position, float v) {
        attach();
        glUniform1f(position, v);
        detach();
        glCheck();
    }

    /// Sets the model-view-projection matrix as "uModelViewProjectionMatrix"
    /// or `name`
    void setMvpMatrix(Matrix4 matrix, string name = "uModelViewProjectionMatrix") {
        int pos = getUniformLocation(name);
        assert(pos != -1, "Cannot find active uniform `" ~ name ~ "` in shader.");

        attach();
        sendUniformMat4(pos, matrix);
        detach();

        glCheck();
    }

    void setTexture(Texture texture, string name = "texture", int location = 0) {
        uint pos = getUniformLocation(name);
        assert(pos != -1, "Cannot find texture sampler `" ~ name ~ "` in shader.");

        attach();
        texture.bind();
        glActiveTexture(GL_TEXTURE0 + location);
        glUniform1i(pos, location);
        detach();
    }

    // ========== STATIC STUFF ==========

    static ShaderProgram defaultPipeline = null;

    static void createDefaultShaders() {
        if(defaultPipeline) return; // do not recreate

        Shader[] shaders;
        shaders ~= new Shader(defaultVertexShader, Shader.Type.vertex);
        shaders ~= new Shader(defaultFragmentShader, Shader.Type.fragment);
        defaultPipeline = new ShaderProgram(shaders);
    }

    static void createDefaultShaders(string vertex, string fragment) {
        defaultPipeline = null;
        defaultFragmentShader = fragment;
        defaultVertexShader = vertex;
        ShaderProgram.createDefaultShaders();
    }
}

static string defaultFragmentShader  = "#version 120
varying vec4 fColor;
varying vec2 fTexCoord;
uniform sampler2D uTexture0;

void main() {
    gl_FragColor = texture2D(uTexture0, fTexCoord);
    //gl_FragColor = fColor;
    //gl_FragColor = vec4(1.0, 0.0, 0.0, 1.0);
}
";

static string defaultVertexShader = "#version 120
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
