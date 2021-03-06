module derp.graphics.sprite;

import std.stdio;

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
protected:
    Vector2 _scale;
    Texture _texture;
    Color _color = Color(1, 1, 1);
    bool _smooth = true;
    bool _needsUpdate = true;
    Rect _subRect = Rect(0, 0, 1, 1); // these are UV-Coordinates, range 0..1

    VertexBufferObject _vbo;

public:
    this(string name, Texture texture = null, ShaderProgram shader = null) {
        super(name);
        if(texture) {
            texture.initialize();
            this.texture = texture;
        }
        this._vbo = new VertexBufferObject(shader);
    }

    void _updateVertices() {
        // TODO: Maybe this can be done more efficiently by storing the
        // vertices and changing only the updated properties - but it
        // should be fast enough for now.

        VertexData[] vertices;
        auto sx = this.size.x / 2;
        auto sy = this.size.y / 2;
        auto c = this._color;
        auto s = this._subRect;

        // First triangle
        vertices ~= VertexData(-sx, -sy, 0, 0, 0, -1, c.r, c.g, c.b, c.a, s.left,  s.top   ); 
        vertices ~= VertexData( sx, -sy, 0, 0, 0, -1, c.r, c.g, c.b, c.a, s.right, s.top   );
        vertices ~= VertexData( sx,  sy, 0, 0, 0, -1, c.r, c.g, c.b, c.a, s.right, s.bottom);

        // Second triangle
        vertices ~= VertexData( sx,  sy, 0, 0, 0, -1, c.r, c.g, c.b, c.a, s.right, s.bottom);
        vertices ~= VertexData(-sx,  sy, 0, 0, 0, -1, c.r, c.g, c.b, c.a, s.left,  s.bottom);
        vertices ~= VertexData(-sx, -sy, 0, 0, 0, -1, c.r, c.g, c.b, c.a, s.left,  s.top   );

        this._vbo.setVertices(vertices);
    }
    
    void prepareRender(RenderQueue queue) {
        queue.push(cast(Renderable) this);
    }

    void render(RenderQueue queue) {
        if(this._needsUpdate) {
            this._updateVertices();
        }
        
       // setDepthTestMode(DepthTestMode.LessEqual);
       // setBlendMode(BlendMode.Blend);
        
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
        glTexParameteri (GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, this._smooth ? GL_LINEAR : GL_NEAREST);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, this._smooth ? GL_LINEAR : GL_NEAREST);
        
        this._vbo.shaderProgram.attach();
        this._vbo.shaderProgram.setTexture(this._texture, "uTexture0", 0);
        this._vbo.render(this.node.derivedMatrix, queue.camera.viewMatrix, queue.camera.projectionMatrix);
    }

    @property Texture texture() {
        return this._texture;
    }

    @property void texture(Texture texture) {
        this._texture = texture;
        this.size = Vector2(1, 1);
        this._needUpdate = true;
    }

    @property bool smooth() {
        return this._smooth;
    }

    @property void smooth(bool smooth) {
        this._smooth = smooth;
    }


    @property Color color() {
        return this._color;
    }

    @property void color(Color color) {
        this._color = color;
        this._needsUpdate = true;    
    }

    @property Rect subRect() {
        return this._subRect;
    }

    @property void subRect(Rect subRect) {
        this._subRect = subRect;
        this._needsUpdate = true;    
    }


    /*
        scale: size relative to texture.size
        size: size in pixels = scale * texture.size
    */

    /// Returns the scale relative to the size of the texture.
    @property Vector2 scale() {
        return this._scale;
    }

    /// Sets the scale relative to the size of the texture.
    @property void scale(Vector2 scale) {
        this._scale = scale;
        this._needsUpdate = true;
    }

    /// ditto
    @property void scale(float scale) {
        this.scale = Vector2(scale, scale);
    }

    /// Returns the size in pixels.
    @property Vector2 size() {
        return Vector2(this._texture.size.x * this._scale.x, 
                this._texture.size.y * this._scale.y);
    }

    /// Sets the size in pixels.
    @property void size(Vector2 size) {
        this._scale.x = size.x / this._texture.size.x;
        this._scale.y = size.y / this._texture.size.y;
        this._needsUpdate = true;
    }

    /// Sets the size in pixels. Will result in a square.
    @property void size(float size) {
        this.size = Vector2(size, size);
    }
}
