/**
 * Creates and manages windows.
 */

module derp.graphics.window;

import std.stdio;
import std.string;

import derelict.opengl3.gl3;
import derelict.glfw3.glfw3;
import derelict.devil.il;
import derelict.devil.ilu;
import derelict.devil.ilut;

import derp.math.all;
import derp.core.geo;
import derp.core.input;
import derp.graphics.util;
import derp.graphics.draw;
import derp.graphics.view;

class Window : Context {
public:
    enum Mode {
        Windowed = GLFW_WINDOWED,
        Fullscreen = GLFW_FULLSCREEN
    }

    Color backgroundColor;

private:
    GLFWwindow _glfwWindow;
    Viewport[] _viewports;

public:
    enum ViewportType {
        None,
        Viewport,
        Viewport2D
    }

    this(string title, int width, int height, Mode mode = Mode.Windowed, bool vsync = true, ViewportType defaultViewportType = ViewportType.Viewport2D) {
        // try to initialize the graphics environment
        initializeGraphics(this);

        this._glfwWindow = glfwOpenWindow(width, height, mode, title.toStringz(), null);
        if(!this._glfwWindow) {
            throw new GraphicsException("Cannot initialize window " ~ title, this);
        }

        // Ensure we can capture the escape key being pressed below
        glfwSetInputMode(this._glfwWindow, GLFW_STICKY_KEYS, GL_TRUE);

        // Enable vertical sync (on cards that support it)
        if(vsync) glfwSwapInterval(1);

        this.activate();

        if(defaultViewportType == ViewportType.Viewport) {
            this._viewports ~= new Viewport(null, this.bounds);
        } else if(defaultViewportType == ViewportType.Viewport2D) {
            this._viewports ~= new Viewport2D(this.bounds);
        }
    }

    @property Viewport[] viewports() {
        return this._viewports;
    }

    void getBounds(ref int x, ref int y, ref int w, ref int h) {
        glfwGetWindowPos(this._glfwWindow, &x, &y);
        glfwGetWindowSize(this._glfwWindow, &w, &h);
    }

    @property Rect bounds() {
        int x, y, w, h;
        glfwGetWindowPos(this._glfwWindow, &x, &y);
        glfwGetWindowSize(this._glfwWindow, &w, &h);
        return Rect(x, y, w, h);
    }

    @property Vector2 size() {
        return this.bounds.size;
    }

    @property uint width() {
        return cast(uint)this.bounds.size.x;
    }

    @property uint height() {
        return cast(uint)this.bounds.size.y;
    }

    @property Vector2 pos() {
        return this.bounds.pos;
    }

    void close() {
        if(this.isOpen()) {
            glfwCloseWindow(this._glfwWindow);
        }
    }

    bool isOpen() {
        return cast(bool) glfwIsWindow(this._glfwWindow);
    }

    void activate() {
        reloadGraphics(this);
    }

    void update() {
        int x, y;
        glfwGetMousePos(this._glfwWindow, &x, &y);

        int w, h;
        glfwGetWindowSize(this._glfwWindow, &w, &h);
    }

    void render() {
        foreach(ref v; this._viewports) {
            v.render(this);
        }
    }

    void clear() {
        this.clear(this.backgroundColor);
    }

    void clear(Color color) {
        // glViewport(0, 0, 20, 20);
        glClearColor(color.r, color.g, color.b, color.a);
        glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
    }

    void display() {
        _currentInputWindow = this;
        glfwSwapBuffers();
        glfwPollEvents();
        _currentInputWindow = null;
    }

    void setViewport(Rect bounds) {
        glViewport(cast(int)bounds.pos.x, cast(int)bounds.pos.y,
            cast(int)bounds.size.x, cast(int)bounds.size.y);
    }

    void saveScreenshot(string filename) {
        ubyte[] data = new ubyte[this.width * this.height * 3];
        glReadPixels(0, 0, this.width, this.height, GL_RGB, GL_UNSIGNED_BYTE, data.ptr); 

        uint ilHandle;

        // Save the image
        ilEnable(IL_FILE_OVERWRITE);
        ilGenImages(1, &ilHandle);
        ilBindImage(ilHandle);
        ilTexImage(this.width, this.height, 1, 3, IL_RGB, IL_UNSIGNED_BYTE, data.ptr);

        // Save image
        ilSave(IL_PNG, filename.toStringz());
        ilDeleteImages(1, &ilHandle);
    }

    void keyPressed(int key) {
        if(key == Input.Key.Escape)
            close();
    }
    void keyReleased(int key) {}
    void unicodePressed(dchar unicode) {}
    void mouseButtonPressed(int button) {}
    void mouseButtonReleased(int button) {}
}
