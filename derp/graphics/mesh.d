module derp.graphics.mesh;

import std.stdio;
import std.string;
import std.conv;
import std.path;

import derelict.opengl3.gl3;
import derelict.assimp.assimp;

import derp.math.all;
import derp.core.geo;
import derp.core.resources;
import derp.core.scene;
import derp.graphics.vertexbuffer;
import derp.graphics.draw;
import derp.graphics.view;
import derp.graphics.texture;
import derp.graphics.shader;
import derp.graphics.render;

static bool _assimpInitialized = false;
void initializeAssimp() {
    if(!_assimpInitialized) {
        DerelictASSIMP.load();
        _assimpInitialized = true;
    }
}

class Scene : Resource {
private:
    const(aiScene)* _scene;

public:
    /// Load the data from the resource loader and interpret it using
    /// ASSIMP. Save the whole scene into _scene.
    void initialize(string format = "") {
        initializeAssimp();

        if(format == "") {
            try {
                format = (cast(UrlString)this.source).url.extension();
            } catch(Exception e) {
                assert(false, "Cannot extract file type from extension, please provide a file type manually.");
            }
        }

        this._scene = aiImportFileFromMemory(
            cast(const(char)*)this.data.ptr,
            cast(uint)this.data.length,
            cast(uint)(
                aiPostProcessSteps.CalcTangentSpace         | 
                aiPostProcessSteps.Triangulate              |
                aiPostProcessSteps.JoinIdenticalVertices    |
                aiPostProcessSteps.GenNormals               |
                aiPostProcessSteps.FlipWindingOrder         |
                aiPostProcessSteps.SortByPType),
            format.toStringz());
        writeln("LOADED.");

        if(this._scene is null) {
            const(char)* e = aiGetErrorString();
            string s = to!string(e);
            writeln(s);
            assert(false, "Scene could not be loaded by ASSIMP.");
        }

        writefln("Loaded scene %s with %s textures.", this.name, this._scene.mNumTextures);
        foreach(s; this.meshNames)
            writeln("Mesh: ", s, ";");
    }

    @property string[] meshNames() {
        string[] names;
        for(uint i = 0; i < this._scene.mNumMeshes; ++i) {
            names ~= to!string(cast(char[])this._scene.mMeshes[i].mName.data);
        }
        return names;
    }

    MeshData getMesh(uint index) {
        MeshData data = new MeshData();

        const(aiMesh*) mesh = this._scene.mMeshes[index];
        for(uint i = 0; i < mesh.mNumFaces; ++i) {
            const(aiFace) face = mesh.mFaces[i];

            // since we triangulated, we can assume exactly 3 vertices per face
            // (triangles only)
            for(uint v = 0; v < 3; ++v) {
                aiVector3D p, n, uv;

                uint vertex = face.mIndices[v];
                p = mesh.mVertices[vertex];
                n = mesh.mNormals[vertex];
                uv = mesh.mTextureCoords[0][vertex];

                data.addVertex(new Vertex(
                            Vector3(p.x, -p.z, p.y),
                            Vector3(n.x, n.z, n.y) * -1,
                            Vector2(uv.x, uv.y)));
            }
        }

        return data;
    }

    Texture getTexture(uint index) {
        return null;
    }
}

class Material {
protected:
    ShaderProgram _shader;

public:
    Texture texture;

    // for now, only use a simple shader program instead of a complex shader
    // node structure
    this(ShaderProgram shader = null) {
        this._shader = (shader is null ? ShaderProgram.defaultPipeline : shader);
        this.texture = Texture.empty;
    }

    @property ShaderProgram shader() {
        return this._shader;
    }

    void activate() {
        this._shader.attach();
        this._shader.setTexture(this.texture, "uTexture0", 0);
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

    void addVertex(Vertex a) {
        this._vertices ~= a.toVertexData();

        this._needUpdate = true;
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

        setDepthTestMode(DepthTestMode.LessEqual);
        setBlendMode(BlendMode.Blend);
        setCullMode(CullMode.Back);

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
