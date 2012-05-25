module derp.graphics.mesh;

import std.stdio;

import derelict.opengl3.gl3;

import derp.core.scene;
import derp.graphics.render;
import derp.graphics.shader;
import derp.graphics.texture;
import derp.graphics.vertexbuffer;

class MeshComponent : Component, Renderable {
private:
    VertexBufferObject _vbo;

public:
    Texture texture;

    this(string name) {
        super(name);
        this._vbo = new VertexBufferObject();
    }

    @property VertexData[] vertices() {
        return this._vbo.vertices;
    }

    @property void vertices(VertexData[] vertices) {
        this._vbo.vertices = vertices;
    }

    void prepareRender(RenderQueue queue) {
        queue.push(this);
    }

    void render(RenderQueue queue) {
        glEnable(GL_BLEND);
        glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
        glTexParameteri (GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        
        // shader attach
        ShaderProgram shader = ShaderProgram.defaultPipeline;
        shader.attach();
        shader.setTexture(this.texture, "uTexture0", 0);
        this._vbo.render(shader, this.node.derivedMatrix, queue.camera.viewMatrix, queue.camera.projectionMatrix);
    }
}
