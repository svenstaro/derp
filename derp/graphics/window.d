/**
 * Creates and manages windows.
 */

module derp.graphics.window;

import std.stdio;
import std.string;

import derp.graphics.draw;

import derelict.opengl3.gl3;
import derelict.glfw3.glfw3;

static bool graphicsInitialized = false;

void initializeGraphics(Context context = null) {
    if(graphicsInitialized) return;

    writeln("Initializing Graphics...");
    DerelictGL3.load();
    DerelictGLFW3.load();

    if(!glfwInit())
        throw new GraphicsException("Failed to initialize GLFW.", context);

    writeln("GLFW Initializes");

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

    string title;
    int width;
    int height;
    int depth = 32;
    Mode mode = Mode.Windowed;
    GLFWwindow glfwWindow;

    this(string title, int width, int height, int depth = 32, Mode mode = Mode.Windowed) {
        // try to initialize the graphics environment
        initializeGraphics(this);

        this.title = title;
        this.width = width;
        this.height = height;
        this.depth = depth;
        this.mode = mode;

        this.open();
    }

    void open() {
        writeln("Opening Window");

        glfwWindow = glfwOpenWindow(this.width, this.height, this.mode, this.title.toStringz(), null);
        if(!glfwWindow) {
            throw new GraphicsException("Cannot initialize window " ~ this.title, this);
        }

        // Ensure we can capture the escape key being pressed below
        glfwSetInputMode(glfwWindow, GLFW_STICKY_KEYS, GL_TRUE);

        // Enable vertical sync (on cards that support it)
        glfwSwapInterval(1);

        this.activate();
    }

    void close() {
        glfwCloseWindow(glfwWindow);
    }

    bool isOpen() {
        return cast(bool) glfwWindow;
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

    void clear(Color color = new Color(0, 0, 0)) {
        glClearColor(color.r, color.g, color.b, color.a);
        glClear(GL_COLOR_BUFFER_BIT);
    }

    void display() {
        glfwSwapBuffers();
    }
}
