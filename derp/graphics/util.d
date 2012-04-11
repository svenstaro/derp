/**
 * Creates and manages windows.
 */

module derp.graphics.util;

import std.stdio;
import std.string;

import derelict.opengl3.gl3;
import derelict.glfw3.glfw3;
import derelict.devil.il;
import derelict.devil.ilu;
import derelict.devil.ilut;

import derp.core.input;

static bool graphicsInitialized = false;

void initializeGraphics(Context context = null) {
    if(graphicsInitialized) return;

    DerelictGL3.load();
    DerelictGLFW3.load();

    if(!glfwInit())
        throw new GraphicsException("Failed to initialize GLFW.", context);

    // reloadGraphics(context);

    DerelictIL.load();

    /*if (ilGetInteger(IL_VERSION_NUM) < IL_VERSION ||
        iluGetInteger(ILU_VERSION_NUM) < ILU_VERSION ||
        ilutGetInteger(ILUT_VERSION_NUM) < ILUT_VERSION) {
        throw new GraphicsException("Outdated DevIL version.", context);
    }*/

    ilInit();
    //iluInit();
    //ilutInit();

    // ilutRenderer(ILUT_OPENGL);

    initializeInput();

    graphicsInitialized = true;
}

void reloadGraphics(Context context) {
    // make sure the graphics system is initialized
    initializeGraphics(context);

    GLVersion glVersion = DerelictGL3.reload();
    writefln("Loaded OpenGL Version %s", glVersion);
}

void deinitializeGraphics() {
    if(!graphicsInitialized) return;
    glfwTerminate();
}


class GraphicsException : Exception {
    Context context;

    this(string text, Context context) {
        super("Error in graphics context: " ~ text);
    }
}

interface Context {
    void activate();
}

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

bool ilCheck(string file = __FILE__, int line = __LINE__) {
    int error = ilGetError();
    if (error == IL_NO_ERROR) return true;

    write(format("[[ %s:%s ]]", file, line));

    while (error != IL_NO_ERROR) {
        writefln("%s (%s)", iluErrorString(error), error);
    }
    return false;
}
