module derp.graphics.mesh;

import std.stdio;

import derelict.opengl3.gl3;

import derp.graphics.draw;
import derp.math.all;
import derp.core.scene;
import derp.graphics.vertexdata;
import derp.graphics.texture;
import derp.graphics.shader;
import derp.graphics.render;

struct Triangle {
    Vector3[3] position;
    Vector3[3] normals;
    Vector2[2] texcoord;
}

struct Material {
    Color ambient = Color(0.2f, 0.2f, 0.2f, 1.0f);
    Color diffuse = Color(0.8f, 0.8f, 0.8f, 1.0f);
    Color specular = Color(0.0f, 0.0f, 0.0f, 1.0f);
    Color emissive = Color(0.0f, 0.0f, 0.0f, 1.0f);
    float shininess = 0.2f * 128;
}

class MeshComponent : Component, Renderable{
protected:
    Vector2 _scale;
    Texture _texture = null;
    bool _smooth = true;
    VertexData[] _vertices;
    IndexData[] _indices;
    VertexArrayObject _vao;

public:
    this(string name) {
        super(name);
        this._vao = new VertexArrayObject();
        assert(this._vao);
    }    

    @property vertices(VertexData[] vertices) {
        this._vao.vertices = vertices;
    }
    
    @property VertexData[] vertices() {
        return this._vao.vertices;
    }
    
    @property indices(IndexData[] indices) {
        this._vao.indices = indices;
    }
    
    @property IndexData[] indices() {
        return this._vao.indices;
    }
    
    void prepareRender(RenderQueue queue) {
        queue.push(cast(Renderable)this);
    }

    void render(RenderQueue queue) {
        setDepthTestMode(DepthTestMode.LessEqual);
        setBlendMode(BlendMode.Add);
        //setCullMode(CullMode.Back);

        //~ glClearStencil(0);
        //~ glEnable(GL_STENCIL_TEST);
        //~ glEnable(GL_BLEND);
        //~ glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
        glTexParameteri (GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, this._smooth ? GL_LINEAR : GL_NEAREST);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, this._smooth ? GL_LINEAR : GL_NEAREST);
        ShaderProgram shader = ShaderProgram.defaultPipeline;
        shader.setTexture(this._texture, "uTexture0", 0);
        this._vao.render(shader, this.node.derivedMatrix, queue.camera.viewMatrix, queue.camera.projectionMatrix);
    }
    
    
    @property Texture texture() {
        return this._texture;
    }

    @property void texture(Texture texture) {
        this._texture = texture;
        this.size = Vector2(1, 1);
        this._needUpdate = true;
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
        this._needUpdate = true;
    }

    /// Sets the size in pixels. Will result in a square.
    @property void size(float size) {
        this.size = Vector2(size, size);
    }
    /// Sets the scale relative to the size of the texture.
    @property void scale(Vector2 scale) {
        this._scale = scale;
        this._needUpdate = true;
    }

    /// ditto
    @property void scale(float scale) {
        this.scale = Vector2(scale, scale);
    }
    /*
        scale: size relative to texture.size
        size: size in pixels = scale * texture.size
    */

    /// Returns the scale relative to the size of the texture.
    @property Vector2 scale() {
        return this._scale;
    }
}


MeshComponent makeCubeMesh(Texture texture) {
    MeshComponent mesh = new MeshComponent("Cube");
    
    float[3] V_PX =  [1.0f, 0.0f, 0.0f];
    float[3] V_NX = [-1.0f, 0.0f, 0.0f];
    float[3] V_PY =  [0.0f, 1.0f, 0.0f];
    float[3] V_NY = [0.0f, -1.0f, 0.0f];
    float[3] V_PZ =  [0.0f, 0.0f, 1.0f];
    float[3] V_NZ = [0.0f, 0.0f, -1.0f];
    
    
    float[2] T_00 = [0.0f, 0.0f];
    float[2] T_01 = [0.0f, 1.0f];
    float[2] T_10 = [1.0f, 0.0f];
    float[2] T_11 = [1.0f, 1.0f];
    
    
    auto f = [
        //back
        VertexData([-1.0f,  1.0f, -1.0f], V_NZ, Color.Red, T_00),
        VertexData([ 1.0f,  1.0f, -1.0f], V_NZ, Color.Red, T_10),
        VertexData([-1.0f, -1.0f, -1.0f], V_NZ, Color.Red, T_01),
        VertexData([-1.0f, -1.0f, -1.0f], V_NZ, Color.Red, T_01),
        VertexData([ 1.0f,  1.0f, -1.0f], V_NZ, Color.Red, T_10),
        VertexData([ 1.0f, -1.0f, -1.0f], V_NZ, Color.Red, T_11),
        //right
        VertexData([ 1.0f,  1.0f, -1.0f], V_PX, Color.Blue, T_00),
        VertexData([ 1.0f,  1.0f,  1.0f], V_PX, Color.Blue, T_10),
        VertexData([ 1.0f, -1.0f, -1.0f], V_PX, Color.Blue, T_01),
        VertexData([ 1.0f, -1.0f, -1.0f], V_PX, Color.Blue, T_01),
        VertexData([ 1.0f,  1.0f,  1.0f], V_PX, Color.Blue, T_10),
        VertexData([ 1.0f, -1.0f,  1.0f], V_PX, Color.Blue, T_11),  
        //front
        VertexData([ 1.0f,  1.0f,  1.0f], V_PZ, Color.Green, T_00),
        VertexData([-1.0f,  1.0f,  1.0f], V_PZ, Color.Green, T_10),
        VertexData([ 1.0f, -1.0f,  1.0f], V_PZ, Color.Green, T_01),
        VertexData([ 1.0f, -1.0f,  1.0f], V_PZ, Color.Green, T_01),
        VertexData([-1.0f,  1.0f,  1.0f], V_PZ, Color.Green, T_10),
        VertexData([-1.0f, -1.0f,  1.0f], V_PZ, Color.Green, T_11),
        //left
        VertexData([-1.0f,  1.0f,  1.0f], V_NX, Color.Yellow, T_00),
        VertexData([-1.0f,  1.0f, -1.0f], V_NX, Color.Yellow, T_10),
        VertexData([-1.0f, -1.0f,  1.0f], V_NX, Color.Yellow, T_01),
        VertexData([-1.0f, -1.0f,  1.0f], V_NX, Color.Yellow, T_01),
        VertexData([-1.0f,  1.0f, -1.0f], V_NX, Color.Yellow, T_10),
        VertexData([-1.0f, -1.0f, -1.0f], V_NX, Color.Yellow, T_11),
        //top
        VertexData([-1.0f,  1.0f,  1.0f], V_PY, Color.Cyan, T_00),
        VertexData([ 1.0f,  1.0f,  1.0f], V_PY, Color.Cyan, T_10),
        VertexData([-1.0f,  1.0f, -1.0f], V_PY, Color.Cyan, T_01),
        VertexData([-1.0f,  1.0f, -1.0f], V_PY, Color.Cyan, T_01),
        VertexData([ 1.0f,  1.0f,  1.0f], V_PY, Color.Cyan, T_10),
        VertexData([ 1.0f,  1.0f, -1.0f], V_PY, Color.Cyan, T_11),
        //bottom
        VertexData([-1.0f, -1.0f, -1.0f], V_NY, Color.Magenta, T_00),
        VertexData([ 1.0f, -1.0f, -1.0f], V_NY, Color.Magenta, T_10),
        VertexData([-1.0f, -1.0f,  1.0f], V_NY, Color.Magenta, T_01),
        VertexData([-1.0f, -1.0f,  1.0f], V_NY, Color.Magenta, T_01),
        VertexData([ 1.0f, -1.0f, -1.0f], V_NY, Color.Magenta, T_10),
        VertexData([ 1.0f, -1.0f,  1.0f], V_NY, Color.Magenta, T_11),
        
            //~ VertexData([-1.0, -1.0,  1.0] ,V_NY, Color.Magenta, T_00),
            //~ VertexData([1.0, -1.0,  1.0], V_NY, Color.Cyan, T_10),
            //~ VertexData([-1.0,  1.0,  1.0] ,V_NY, Color.Yellow, T_00),
            //~ VertexData([1.0,  1.0,  1.0] ,V_NY, Color.Green, T_11),
            
            //~ VertexData([-1.0, -1.0, -1.0] ,V_NY, Color.Blue, T_00),
            //~ VertexData([1.0, -1.0, -1.0] ,V_NY, Color.Red, T_00),
            //~ VertexData([-1.0,  1.0, -1.0] ,V_NY, Color.White, T_00),
            //~ VertexData([1.0,  1.0, -1.0] ,V_NY, Color.Black, T_00),
        ];
    mesh.vertices = f;
    //mesh.texture = texture;
    return mesh;
}




//~ this._vao.setIndices([
            //~ 3,2,0,0,1,3,//f    
            //~ 6,7,5,5,4,6,//b     
            //~ 7,3,1,1,5,7,//r     
            //~ 2,6,4,4,0,2,//l     
            //~ 7,6,2,2,3,7,//t
            //~ 1,0,4,4,5,1,//b        
        //~ ]);