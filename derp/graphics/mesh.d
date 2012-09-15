module derp.graphics.mesh;

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

class Material {
protected:
    ShaderProgram _shader;

public:
    // for now, only use a simple shader program instead of a complex shader
    // node structure
    this(ShaderProgram shader = null) {
        this._shader = (shader is null ? ShaderProgram.defaultPipeline : shader);
    }

    @property ShaderProgram shader() {
        return this._shader;
    }

    void activate() {
        this._shader.attach();
        this._shader.setTexture(Texture.empty, "uTexture0", 0);
        // ShaderProgram.defaultPipeline.
        // this._vbo.shaderProgram.attach();
        // this._vbo.shaderProgram.setTexture(this._texture, "uTexture0", 0);
    }
}

class MeshData {
protected:
    VertexData[] _vertices;
    
    bool _needUpdate;
    VertexBufferObject _previousVertexBufferObject;

public:
    @property VertexData[] vertices() {
        return this._vertices;
    }

    void update(VertexBufferObject vbo) {
        if(this._needUpdate || vbo != this._previousVertexBufferObject) {
            vbo.setVertices(this._vertices);

            this._needUpdate = false;
            this._previousVertexBufferObject = vbo;
        }
    }

    void addTriangle(Vertex a, Vertex b, Vertex c) {
        this._vertices ~= a.toVertexData();
        this._vertices ~= b.toVertexData();
        this._vertices ~= c.toVertexData();

        this._needUpdate = true;
    }

    void addQuad(Vertex a, Vertex b, Vertex c, Vertex d) {
        this._vertices ~= a.toVertexData();
        this._vertices ~= b.toVertexData();
        this._vertices ~= c.toVertexData();

        this._vertices ~= a.toVertexData();
        this._vertices ~= c.toVertexData();
        this._vertices ~= d.toVertexData();

        this._needUpdate = true;
    }
}

class MeshComponent : Component, Renderable {
protected:
    Material _material;
    MeshData _data;
    bool _needsUpdate = true;
    VertexBufferObject _vbo;

public:
    this(string name, MeshData data, Material material) {
        super(name);
        this._data = data;
        this._material = material;
        this._vbo = new VertexBufferObject(material.shader);
    }

    void _updateVertices() {
        this._vbo.setVertices(this._data.vertices);
    }
    
    void prepareRender(RenderQueue queue) {
        queue.push(cast(Renderable) this);
    }

    void render(RenderQueue queue) {
        if(this._needsUpdate) {
            this._updateVertices();
        }

        glEnable(GL_BLEND);
        glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
        glTexParameteri (GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        
        this._material.activate();
        this._vbo.render(this.node.derivedMatrix, queue.camera.viewMatrix, queue.camera.projectionMatrix);
    }

    @property MeshData data() {
        return this._data;
    }

    @property void data(MeshData data) {
        this._data = data;
        this._needUpdate = true;
    }

    @property Material material() {
        return this._material;
    }

    @property void material(Material material) {
        this._material = material;
        this._needUpdate = true;
    }
}
