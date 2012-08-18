module derp.graphics.shader;

import std.string;
import std.conv;
import std.traits;

import derelict.opengl3.gl3;
import derelict.glfw3.glfw3;
import derp.math.all;
import gl3n.linalg;


import derp.core.shapes;
import derp.graphics.util;
import derp.graphics.draw;
import derp.graphics.view;
import derp.graphics.texture;

import std.array;

import derp.graphics.vertexdata;

alias string ShaderAttribute;

class Shader {
public:
    enum Type {
        Vertex      = GL_VERTEX_SHADER,
        TessControl = GL_TESS_CONTROL_SHADER, 
        TessEvaluation = GL_TESS_EVALUATION_SHADER,
        Geometry    = GL_GEOMETRY_SHADER,
        Fragment    = GL_FRAGMENT_SHADER
    }
    
private:    
    string _source;
    Type _type;
    int _hShader;

    this(string source, Type type) {
        this._source = source;
        this._type = type;
        create();
    }

    delete(void* shader) {
        (cast(Shader)shader).destroy();
    }

    void create() {
        this._hShader = glCreateShader(this._type);
        // writefln("Created Shader %s", this.handle);
        const char* source = this._source.toStringz();
        glShaderSource(this._hShader, 1, &source, null);
        glCheck();
        glCompileShader(this._hShader);
        glCheck();

        string info = infoLog;
        if(info != "") writeln(info);
        assert(info == "", "failed to compile shader.");
    }

    @property string infoLog() {
        int len;
        glGetShaderiv(this._hShader, GL_INFO_LOG_LENGTH , &len);
        if (len > 1) {
            char[] msg = new char[len];
            glGetShaderInfoLog(this._hShader, len, null, cast(char*) msg);
            return cast(string)msg;
        }
        return "";
    }

    void destroy() {
        glDeleteShader(this._hShader);
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
    int _hShaderProgram;
    int[string] _uniformLocationCache;
    int[string] _attribLocationCache;
    bool _isAttached = false;
public:
    this(Shader[] shaders) {
        this.create(shaders);
    }

    delete(void* shaderProgram) {
        (cast(ShaderProgram)shaderProgram).destroy();
    }
    
    @property bool isAttached() {
        return this._isAttached;
    }

    @property string infoLog() {
        int len;
        glGetProgramiv(this._hShaderProgram, GL_INFO_LOG_LENGTH , &len);
        if (len > 1) {
            char[] msg = new char[len];
            glGetProgramInfoLog(this._hShaderProgram, len, null, cast(char*) msg);
            return cast(string)msg;
        }
        return "";
    }

    void create(Shader[] shaders) {
        this._hShaderProgram = glCreateProgram();
        assert(glIsProgram(this._hShaderProgram), "Failed to create ShaderProgram.");

        // attach
        foreach(s; shaders) {
            glAttachShader(this._hShaderProgram, s._hShader);
            glCheck();
        }

        // link
        glBindAttribLocation(this._hShaderProgram, 0, "vPosition");
        glBindAttribLocation(this._hShaderProgram, 1, "vNormal");
        glBindAttribLocation(this._hShaderProgram, 2, "vColor");
        glBindAttribLocation(this._hShaderProgram, 3, "vTexCoord");
        glCheck();

        glLinkProgram(this._hShaderProgram);
        glCheck();

        int linkSuccess;
        glGetProgramiv(this._hShaderProgram, GL_LINK_STATUS, &linkSuccess);
        assert(linkSuccess == GL_TRUE, "Linker error.");

        // check here
        string info = infoLog;
        if(info != "") writeln(info);
        assert(info == "", "Failed to link program.");

        int validateSuccess;
        glValidateProgram(this._hShaderProgram);
        glGetProgramiv(this._hShaderProgram, GL_VALIDATE_STATUS, &validateSuccess);
        assert(validateSuccess == GL_TRUE, "Validation error.");

        glCheck();

        // detach
        foreach(s; shaders) {
            glDetachShader(this._hShaderProgram, s._hShader);
            glCheck();
        }
    }

    void destroy() {
        glDeleteProgram(this._hShaderProgram);
        glCheck();
    }

    void attach() {
        glUseProgram(this._hShaderProgram);
        glCheck();
        this._isAttached = true;
    }

    void detach() {
        glUseProgram(0);
        glCheck();
        this._isAttached = false;
    }

    int getUniformLocation(string name) {
        int* px = (name in this._uniformLocationCache);
        if(px !is null)
            return *px;
        const char* n = name.toStringz();
        int x = glGetUniformLocation(this._hShaderProgram, &n[0]);
        glCheck();
        this._uniformLocationCache[name] = x;
        return x;
    }

    int getAttribLocation(string name) {
        int* px = (name in this._attribLocationCache);
        if(px !is null)
            return *px;
        const char* n = name.toStringz();
        int x = glGetAttribLocation(this._hShaderProgram, &n[0]);
        glCheck();
        this._attribLocationCache[name] = x;
        return x;
    }
    
    /// send Uniform
    void sendUniform(T)(int position, T t) {
        assert(this.isAttached, "cannot send uniform, shader not attached");
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
                    mixin("glUniformMatrix"~to!string(T.cols)~"x"~to!string(T.rows)~"fv(position, 1, false, t.value_ptr);");
                else
                    mixin("glUniformMatrix"~to!string(T.cols)~"fv(position, 1, false, t.value_ptr);");
            }
            else static if(isIntegral!(T.mt)) {
                static if(T.cols != T.rows)
                    mixin("glUniformMatrix"~to!string(T.cols)~"x"~to!string(T.rows)~"fi(position, 1, false, t.value_ptr);");
                else
                    mixin("glUniformMatrix"~to!string(T.cols)~"fi(position, 1, false, t.value_ptr);");   
            }
        }
        else
        {
            static assert(false, "Type "~T.stringof~" can not be sent via sendUniform");
        }
        glCheck();
    }
    
    /// send Uniform
    void sendUniform(T)(string name, T t){
        sendUniform(getUniformLocation(name), t);
    }

    void setTexture(Texture texture, string name = "texture", int location = 0) {
        assert(this.isAttached, "cannot send uniform, shader not attached");
        uint pos = getUniformLocation(name);
        assert(pos != -1, "Cannot find texture sampler `" ~ name ~ "` in shader.");

        this.sendUniform(pos, location);
        if(texture is null) {
            glBindTexture(GL_TEXTURE_2D, 0);
        } else {
            texture.bind();
        }
        glActiveTexture(GL_TEXTURE0 + location);
    }

    /**
     * Predefined default pipeline with simple vertex shader and 
     * simple color/texture fragment shader.
     */
    static ShaderProgram _defaultPipeline = null;

    /// ditto
    static @property ShaderProgram defaultPipeline() {
        if(this._defaultPipeline is null) {
            Shader[] shaders;
            shaders ~= new Shader(defaultVertexShader, Shader.Type.Vertex);
            shaders ~= new Shader(defaultFragmentShader, Shader.Type.Fragment);
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
varying vec3 fPosition;
varying vec3 fNormal;
varying vec4 fColor;
varying vec2 fTexCoord;
uniform sampler2D uTexture0;
uniform bool bNoTexture;

// combines two color values
// if the modifier is greater than 1, or less than 0, it adds
// the value (-1 for mod > 1) to the input color, otherwise it multiplies
float colorCombine(float tex, float mod) {
    if (mod > 1 || mod < 0)
        return max(0, min(1, tex + mod - 1));
    else
        return max(0, min(1, tex * mod));
}

void main() {
    vec4 tex = texture2D(uTexture0, fTexCoord);
    gl_FragColor = vec4(
            colorCombine(tex.r, fColor.r),
            colorCombine(tex.g, fColor.g),
            colorCombine(tex.b, fColor.b),
            colorCombine(tex.a, fColor.a)
            );
    //gl_FragColor = texture2D(uTexture0, fTexCoord) * fColor;
}
";

static string defaultVertexShader = "#version 120
struct Color {
    vec4 color;
};
struct Material {
    Color ambient;
    Color diffuse;
    Color specular;
    Color emissive;
    float shininess;
};

uniform mat4 uModelMatrix;
uniform mat4 uViewMatrix;
uniform mat4 uProjectionMatrix;

uniform Material material;

attribute vec3 vPosition;
attribute vec3 vNormal;
attribute vec4 vColor;
attribute vec2 vTexCoord;

varying vec3 fPosition;
varying vec3 fNormal;
varying vec4 fColor;
varying vec2 fTexCoord;

void main() {
    vec4 vPos = uViewMatrix * uModelMatrix * vec4(vPosition, 1.0);
    gl_Position = uProjectionMatrix * vPos;
    
    fPosition = vPos.xyz;
    fNormal = vNormal;
    fColor = vColor;
    fTexCoord = vTexCoord;
}
";
