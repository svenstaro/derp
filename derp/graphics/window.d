/**
 * Creates and manages windows.
 */

module derp.graphics.window;

import std.stdio;
import std.string;

import derp.graphics.draw;
import derp.graphics.view;

import derelict.opengl3.gl3;
import derelict.glfw3.glfw3;

static bool graphicsInitialized = false;

void initializeGraphics(Context context = null) {
    if(graphicsInitialized) return;

    DerelictGL3.load();
    DerelictGLFW3.load();

    if(!glfwInit())
        throw new GraphicsException("Failed to initialize GLFW.", context);

    // reloadGraphics(context);

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

class Window : Context {
    enum Mode {
        Windowed = GLFW_WINDOWED,
        Fullscreen = GLFW_FULLSCREEN
    }

    GLFWwindow glfwWindow;
    Color backgroundColor;

    this(string title, int width, int height, Mode mode = Mode.Windowed, bool vsync = true) {
        // try to initialize the graphics environment
        initializeGraphics(this);

        glfwWindow = glfwOpenWindow(width, height, mode, title.toStringz(), null);
        if(!glfwWindow) {
            throw new GraphicsException("Cannot initialize window " ~ title, this);
        }

        // Ensure we can capture the escape key being pressed below
        glfwSetInputMode(glfwWindow, GLFW_STICKY_KEYS, GL_TRUE);

        // Enable vertical sync (on cards that support it)
        if(vsync) glfwSwapInterval(1);

        this.activate();
        this.setViewport(getBounds()); // set full viewport
    }

    void getBounds(ref int x, ref int y, ref int w, ref int h) {
        glfwGetWindowPos(this.glfwWindow, &x, &y);
        glfwGetWindowSize(this.glfwWindow, &w, &h);
    }

    Rect getBounds() {
        int x, y, w, h;
        glfwGetWindowPos(this.glfwWindow, &x, &y);
        glfwGetWindowSize(this.glfwWindow, &w, &h);
        return Rect(x, y, w, h);
    }

    void close() {
        if(this.isOpen()) {
            glfwCloseWindow(glfwWindow);
        }
    }

    bool isOpen() {
        return cast(bool) glfwIsWindow(glfwWindow);
    }

    void activate() {
        reloadGraphics(this);
    }

    void update() {
        int x, y;
        glfwGetMousePos(glfwWindow, &x, &y);

        int w, h;
        glfwGetWindowSize(glfwWindow, &w, &h);
    }

    void clear() {
        this.clear(this.backgroundColor);
    }

    void clear(Color color) {
        // glViewport(0, 0, 20, 20);
        glClearColor(color.r, color.g, color.b, color.a);
        glClear(GL_COLOR_BUFFER_BIT);
    }

    void display() {
        glfwSwapBuffers();
        glfwPollEvents();
    }

    void setViewport(Rect bounds) {
        glViewport(cast(int)bounds.pos.x, cast(int)bounds.pos.y,
            cast(int)bounds.size.x, cast(int)bounds.size.y);
    }
}