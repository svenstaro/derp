/**
 * Rendering stuff, render queues and renderable interface.
 */

module derp.graphics.render;

import derp.graphics.camera;
import derp.graphics.view;
import std.stdio;

interface Renderable {
    void render(RenderQueue queue);
    // void prepareRender(RenderQueue queue);
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
	    writeln("queue.renderall");
        foreach(renderable; _queue) {
		writeln("queue.renderall _call: renderable.render");
            renderable.render(this);
        }
    }

}
