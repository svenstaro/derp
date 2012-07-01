/**
 * Rendering stuff, render queues and renderable interface.
 */

module derp.graphics.render;

import derp.graphics.camera;
import derp.graphics.view;
import std.stdio;

import derelict.opengl3.gl3;

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
        foreach(renderable; _queue) {
            renderable.render(this);
        }
    }

}

enum CullMode {
    None,
    Back,
    Front
}

enum BlendMode {
    Replace,
    Blend,
    Add,
    AddBlended,
    Mult
}

enum DepthTestMode {
    None,
    Always,
    Equal,
    Less,
    Greater,
    LessEqual,
    GreaterEqual
}

//Set Cull Mode
void setCullMode(CullMode cm) {
    final switch(cm) {
    case CullMode.Back:
        glEnable(GL_CULL_FACE);
        glCullFace(GL_BACK);
        break;
    case CullMode.Front:
        glEnable(GL_CULL_FACE);
        glCullFace(GL_FRONT);
        break;
    case CullMode.None:
        glDisable(GL_CULL_FACE);
        break;
    }
}

///Set Blend Mode
void setBlendMode(BlendMode bm) {
    final switch(bm)
    {
    case BlendMode.Replace:
        glDisable(GL_BLEND);
        break;
    case BlendMode.Blend:
        glEnable(GL_BLEND);
        glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
        break;
    case BlendMode.Add:
        glEnable(GL_BLEND);
        glBlendFunc(GL_ONE, GL_ONE);
        break;
    case BlendMode.AddBlended:
        glEnable(GL_BLEND);
        glBlendFunc(GL_SRC_ALPHA, GL_ONE);
        break;
    case BlendMode.Mult:
        glEnable(GL_BLEND);
        glBlendFunc(GL_DST_COLOR, GL_ZERO);
        break;
    }
}


///Set Depth Test
void setDepthTestMode(DepthTestMode dt) {
    final switch(dt)
    {
    case DepthTestMode.None:
        glDisable(GL_DEPTH_TEST);
        break;
    case DepthTestMode.Always:
        glEnable(GL_DEPTH_TEST);
        glDepthFunc(GL_ALWAYS);
        break;
    case DepthTestMode.Equal:
        glEnable(GL_DEPTH_TEST);
        glDepthFunc(GL_EQUAL);
        break;
    case DepthTestMode.Less:
        glEnable(GL_DEPTH_TEST);
        glDepthFunc(GL_LESS);
        break;
    case DepthTestMode.Greater:
        glEnable(GL_DEPTH_TEST);
        glDepthFunc(GL_GREATER);
        break;
    case DepthTestMode.LessEqual:
        glEnable(GL_DEPTH_TEST);
        glDepthFunc(GL_LEQUAL);
        break;
    case DepthTestMode.GreaterEqual:
        glEnable(GL_DEPTH_TEST);
        glDepthFunc(GL_GEQUAL);
        break;
    }
}
