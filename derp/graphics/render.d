/**
 * Rendering stuff, render queues and renderable interface.
 */

module derp.graphics.render;

import derp.graphics.camera;
import derp.graphics.view;
import std.stdio;
public import derp.graphics.util;

import derelict.opengl3.gl3;

interface Renderable {
    void render(RenderQueue queue);
    // void prepareRender(RenderQueue queue); // this is in Component itself
}

class RenderQueue {
private:
    Renderable[] _queue;

public:
    CameraComponent camera;
    Viewport viewport;

    this(CameraComponent camera = null, Viewport viewport = null) {
        this.camera = camera;
        this.viewport = viewport;
    }

    void push(Renderable renderable) {
        // TODO: Maybe we will sort them here
        // TODO: View culling here (?)
        _queue ~= renderable;
    }

    void renderAll() {
        foreach(renderable; _queue) {
            renderable.render(this);
        }
    }

}

abstract class Renderer {
public:
    string name;

    this(string name) {
        this.name = name;
    }

    void render(RenderQueue queue);
}

class ForwardRenderer : Renderer {
    this() {
        super("Derp Forward Renderer");
    }

    void render(RenderQueue queue) {

    }
}
