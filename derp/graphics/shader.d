module derp.graphics.shader;

import std.string;
import std.conv;
import std.traits;

import derelict.opengl3.gl3;
import derelict.glfw3.glfw3;
import gl3n.linalg;
import gl3n.util : isVector = is_vector, isMatrix = is_matrix;

import derp.core.geo;
import derp.graphics.util;
import derp.graphics.draw;
import derp.graphics.view;
import derp.graphics.texture;

import std.array;

class Shader {
public:
    enum Type {
        vertex      = GL_VERTEX_SHADER,
        fragment    = GL_FRAGMENT_SHADER,
        geometry    = GL_GEOMETRY_SHADER
    }
    
private:    
    string _source;
    Type _type;
    int _handle;

    this(string source, Type type) {
        this._source = source;
        this._type = type;
        create();
    }

    delete(void* shader) {
        (cast(Shader)shader).destroy();
    }

    void create() {
        this._handle = glCreateShader(this._type);
        // writefln("Created Shader %s", this.handle);
        const char* source = this._source.toStringz();
        glShaderSource(this._handle, 1, &source, null);
        glCheck();
        glCompileShader(this._handle);
        glCheck();

        string info = infoLog;
        if(info != "") writeln(info);
        assert(info == "", "failed to compile shader.");
    }

    @property string infoLog() {
        int len;
        glGetShaderiv(this._handle, GL_INFO_LOG_LENGTH , &len);
        if (len > 1) {
            char[] msg = new char[len];
            glGetShaderInfoLog(this._handle, len, null, cast(char*) msg);
            return cast(string)msg;
        }
        return "";
    }

    void destroy() {
        glDeleteShader(this._handle);
        glCheck();
    }
}

import std.stdio;

/**
 *  This is a shading program, consisting of multiple shaders
 *  (usually a vertex and a fragment shader).
 */
final class ShaderProgram {
private:
    int _handle;
    int[string] _uniformLocationCache;
    int[string] _attribLocationCache;
public:
    this(Shader[] shaders) {
        this.create(shaders);
    }

    delete(void* shaderProgram) {
        (cast(ShaderProgram)shaderProgram).destroy();
    }

    @property string infoLog() {
        int len;
        glGetProgramiv(this._handle, GL_INFO_LOG_LENGTH , &len);
        if (len > 1) {
            char[] msg = new char[len];
            glGetProgramInfoLog(this._handle, len, null, cast(char*) msg);
            return cast(string)msg;
        }
        return "";
    }

    void create(Shader[] shaders) {
        this._handle = glCreateProgram();
        assert(glIsProgram(this._handle), "Failed to create ShaderProgram.");

        // attach
        foreach(s; shaders) {
            glAttachShader(this._handle, s._handle);
            glCheck();
        }

        // link
        glBindAttribLocation(this._handle, 0, "vVertex");
        glBindAttribLocation(this._handle, 1, "vColor");
        glBindAttribLocation(this._handle, 2, "vTexCoord");
        glCheck();


        glLinkProgram(this._handle);
        glCheck();

        int linkSuccess;
        glGetProgramiv(this._handle, GL_LINK_STATUS, &linkSuccess);
        assert(linkSuccess == GL_TRUE, "Linker error.");

        // check here
        string info = infoLog;
        if(info != "") writeln(info);
        assert(info == "", "Failed to link program.");

        int validateSuccess;
        glValidateProgram(this._handle);
        glGetProgramiv(this._handle, GL_VALIDATE_STATUS, &validateSuccess);
        assert(validateSuccess == GL_TRUE, "Validation error.");

        glCheck();

        // detach
        foreach(s; shaders) {
            glDetachShader(this._handle, s._handle);
            glCheck();
        }
    }

    void destroy() {
        glDeleteProgram(this._handle);
        glCheck();
    }

    void attach() {
        glUseProgram(this._handle);
        glCheck();
    }

    void detach() {
        glUseProgram(0);
        glCheck();
    }

    int getUniformLocation(string name) {
        int* px = (name in this._uniformLocationCache);
        if(px !is null)
            return *px;
        const char* n = name.toStringz();
        int x = glGetUniformLocation(this._handle, &n[0]);
        glCheck();
        this._uniformLocationCache[name] = x;
        return x;
    }

    int getAttribLocation(string name) {
        int* px = (name in this._attribLocationCache);
        if(px !is null)
            return *px;
        const char* n = name.toStringz();
        int x = glGetAttribLocation(this._handle, &n[0]);
        glCheck();
        this._attribLocationCache[name] = x;
        return x;
    }
    
    /// send Uniform
    void sendUniform(T)(int position, T t) {
        attach();
        static if(isFloatingPoint!T) {
            glUniform1f(position, t);
        }
        else static if(isIntegral!T) {
            glUniform1i(position, t);
        }
        else static if(isVector!T && isFloatingPoint!(T.vt)) {
            mixin("glUniform"~to!string(T.dimension)~"fv(position, 1, t.value_ptr);");
        }
        else static if(isVector!T && isIntegral!(T.vt)) {
            mixin("glUniform"~to!string(T.dimension)~"iv(position, 1, t.value_ptr);");
        }
        else static if(isMatrix!T && isNumeric!(T.mt) && T.cols >= 2 && T.cols <= 4 && T.rows >= 2 && T.rows <= 4) {
            static if(isFloatingPoint!(T.mt)) {
                static if(T.cols != T.rows)
                    mixin("glUniformMatrix"~to!string(T.cols)~"x"~to!string(T.rows)~"fv(position, 1, GL_FALSE, t.value_ptr);");
                else
                    mixin("glUniformMatrix"~to!string(T.cols)~"fv(position, 1, false, t.value_ptr);");
            }
            else static if(isIntegral!(T.mt)) {
                static if(T.cols != T.rows)
                    mixin("glUniformMatrix"~to!string(T.cols)~"x"~to!string(T.rows)~"fi(position, 1, GL_FALSE, t.value_ptr);");
                else
                    mixin("glUniformMatrix"~to!string(T.cols)~"fi(position, 1, false, t.value_ptr);");   
            }
        }
        else
        {
            static assert(false, "Type "~T.stringof~" can not be sent via sendUniform");
        }
        detach();
        glCheck();
    }
    
    /// send Uniform
    void sendUniform(T)(string name, T t){
        sendUniform(getUniformLocation(name), t);
    }

    /// Sets the model-view-projection matrix as "uModelViewProjectionMatrix"
    /// or `name`
    void setMvpMatrix(Matrix4 matrix, string name = "uModelViewProjectionMatrix") {
        sendUniform(name, matrix);
    }

    void setTexture(Texture texture, string name = "texture", int location = 0) {
        uint pos = getUniformLocation(name);
        assert(pos != -1, "Cannot find texture sampler `" ~ name ~ "` in shader.");

        attach();
        glUniform1i(pos, location);
        texture.bind();
        glActiveTexture(GL_TEXTURE0 + location);
        detach();
    }

    /**
     * Predefined default pipeline with simple vertex shader and 
     * simple color/texture fragment shader.
     */
    static ShaderProgram _defaultPipeline = null;

    /// ditto
    static @property ShaderProgram defaultPipeline() {
        if(!_defaultPipeline) {
            Shader[] shaders;
            shaders ~= new Shader(defaultVertexShader, Shader.Type.vertex);
            shaders ~= new Shader(defaultFragmentShader, Shader.Type.fragment);
            _defaultPipeline = new ShaderProgram(shaders);
        }
        return _defaultPipeline;
    }

    /**
     * Sets the vertex and fragment shader for the default pipeline. The shaders
     * will be lazily compiled when defaultPipeline is accessed the next time.
     */
    static void setDefaultShaders(string vertex, string fragment) {
        _defaultPipeline = null;
        defaultFragmentShader = fragment;
        defaultVertexShader = vertex;
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
