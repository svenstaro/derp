module derp.graphics.sprite;

import derelict.opengl3.gl3;

import derp.math.all;
import derp.core.geo;
import derp.core.scene;
import derp.graphics.vertexbuffer;
import derp.graphics.draw;
import derp.graphics.view;
import derp.graphics.texture;
import derp.graphics.shader;
import derp.graphics.render;

class SpriteComponent : Component, Renderable {
    Vector2 origin; /// Origin inside the sprite rect. From 0|0 to 1|1 (so the origin stays the same upon resizing).
    Vector2 scale; /// Scale the texture along x and y axis.
    Texture texture;
    bool smooth = true;

    VertexData[] vertices;
    VertexBufferObject vbo;

    this(string name, Texture texture = null, ShaderProgram shader = null) {
        super(name);

        if(texture)
            this.setTexture(texture);

        vbo = new VertexBufferObject(shader);
        vertices ~= VertexData(-0.5, -0.5, 0, 1, 1, 1, 1, 0, 0);
        vertices ~= VertexData( 0.5, -0.5, 0, 1, 1, 1, 1, 1, 0);
        vertices ~= VertexData( 0.5,  0.5, 0, 1, 1, 1, 1, 1, 1);

        vertices ~= VertexData( 0.5,  0.5, 0, 1, 1, 1, 1, 1, 1);
        vertices ~= VertexData(-0.5,  0.5, 0, 1, 1, 1, 1, 0, 1);
        vertices ~= VertexData(-0.5, -0.5, 0, 1, 1, 1, 1, 0, 0);
        this.vbo.setVertices(vertices);
    }
    
    void prepareRender(RenderQueue queue) {
        
        queue.push(this);
    }
    
    void render(RenderQueue queue) {
        glEnable(GL_BLEND);
        glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
        glTexParameteri (GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, smooth ? GL_LINEAR : GL_NEAREST);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, smooth ? GL_LINEAR : GL_NEAREST);
        
        this.vbo.shaderProgram.attach();
        this.vbo.shaderProgram.setTexture(this.texture, "uTexture0", 0);
        this.vbo.render(this.node.derivedMatrix, queue.camera.viewMatrix, queue.camera.projectionMatrix);
    }

    void setTexture(Texture texture) {
        this.texture = texture;
        // for caching, set dirty state here
    }

    void setColor(Color color) {
        for(int i = 0; i < this.vertices.length; ++i) {
            this.vertices[i].r = color.r;
            this.vertices[i].g = color.g;
            this.vertices[i].b = color.b;
            this.vertices[i].a = color.a;
        }
        this.vbo.setVertices(vertices);
    }

    /// Returns the pixel-size of the scaled texture.
    @property Vector2 size() {
        return Vector2(this.texture.size.x * this.scale.x, this.texture.size.y * this.scale.y);
    }


    void setSize(Vector2 size) {
        this.scale.x = size.x / this.texture.size.x;
        this.scale.y = size.y / this.texture.size.y;
    }

    void setScale(float scale) {
        this.scale.x = scale;
        this.scale.y = scale;
    }
}
