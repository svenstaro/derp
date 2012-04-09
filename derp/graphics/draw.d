/**
 * Draws simple shapes.
 */

module derp.graphics.draw;

import std.stdio;
import std.string;

import derelict.opengl3.gl3;
// import derelict.glfw3.glfw3;
// import gl3n.linalg;

bool glCheck(string file = __FILE__, int line = __LINE__) {
    int error = glGetError();
    if (error == GL_NO_ERROR) return true;

    write(format("[[ %s:%s ]]", file, line));

    while(error != GL_NO_ERROR) {
        switch (error) {
            case GL_INVALID_ENUM:
                writeln("GL_INVALID_ENUM: an unacceptable value has been specified for an enumerated argument");
                break;
            case GL_INVALID_VALUE:
                writeln("GL_INVALID_VALUE: a numeric argument is out of range");
                break;
            case GL_INVALID_OPERATION:
                writeln("GL_INVALID_OPERATION: the specified operation is not allowed in the current state");
                break;
            case GL_OUT_OF_MEMORY:
                writeln("GL_OUT_OF_MEMORY: there is not enough memory left to execute the command");
                break;
            case GL_INVALID_FRAMEBUFFER_OPERATION:
                writeln("GL_INVALID_FRAMEBUFFER_OPERATION_EXT: the object bound to FRAMEBUFFER_BINDING_EXT is not \"framebuffer complete\"");
                break;
            default:
                writeln("Error not listed. Value: ", error);
                break;
        }
        error = glGetError();
    }
    return false;
}

struct Color {
    static Color Black          = Color(0, 0, 0);
    static Color DarkGray       = Color(0.2, 0.2, 0.2);
    static Color Gray           = Color(0.5, 0.5, 0.5);
    static Color White          = Color(1, 1, 1);
    static Color Transparent    = Color(0, 0, 0, 0);
    static Color Red            = Color(1, 0, 0);
    static Color Green          = Color(0, 1, 0);
    static Color Blue           = Color(0, 0, 1);
    static Color Yellow         = Color(1, 1, 0);
    static Color Cyan           = Color(0, 1, 1);
    static Color Magenta        = Color(1, 0, 1);

    static Color Background     = Color(0.055, 0.2235, 0.4);

    float r, g, b, a;

    this(float r, float g, float b, float a = 1) {
        this.r = r;
        this.g = g;
        this.b = b;
        this.a = a;
    }
}
