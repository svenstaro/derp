module derp.graphics.vertexbuffer;

import std.stdio;

import derelict.opengl3.gl3;
import derelict.glfw3.glfw3;

import derp.math.all;
import derp.graphics.util;
import derp.graphics.shader;
import derp.graphics.draw;
import derp.graphics.render;

struct SubRect {
    float s;
    float t;
}

struct VertexData {
    union
    {
        struct {
            float[3] position;
            float[3] normal;
            float[4] color;
            float[2] texcoord;
        }
        float[12] _vertices;
    }
    
    
    this(float[3] position, float[3] normal, float[4] color, float[2] texcoord) {
        this.position = position;
        this.normal = normal;
        this.color = color;
        this.texcoord = texcoord;
    }
    
    this(float x = 0, float y = 0, float z = 0, float nx = 0, float ny = 0, float nz = 0, float r = 0, float g = 0, float b = 0, float a = 1, float s = 0, float t = 0) {
        this.position = [x, y, z];
        this.normal = [nx, ny, nz];
        this.color = [r, g, b, a];
        this.texcoord = [s, t];
    }
}

alias uint IndexData;

/**
 */
class VertexArrayObject {
private:
    VertexData[] _vertices;

    uint _vao; // vertex buffer object, keeps track of vertex attributes etc.
    uint _vertexBuffer;
    ulong _vertexCount;
    uint _indexBuffer;
    ulong _indexCount;

public:	
    this() {
        create();
    }

    @property ShaderProgram shaderProgram() {
        return this._shaderProgram;
    }
    
    void create() {
        // Create VBO
        glGenVertexArrays(1, &this._vao);
        glCheck();
        glBindVertexArray(this._vao);
        glCheck();

        // Create the buffer
        glGenBuffers(1, &this._vertexBuffer);
        glCheck();
        glGenBuffers(1, &this._indexBuffer);
        glCheck();

        // Set the buffer's vertex attributes
        glBindBuffer(GL_ARRAY_BUFFER, this._vertexBuffer);
        glCheck();
        glEnableVertexAttribArray(0);
        glEnableVertexAttribArray(1);
        glEnableVertexAttribArray(2);
        glEnableVertexAttribArray(3);
        glCheck();

        // glBindAttribLocation(this.shaderProgram.handle, 0, "_vertex");
        // glBindAttribLocation(this.shaderProgram.handle, 1, "_color");
        // glBindAttribLocation(this.shaderProgram.handle, 2, "_texCoord");
        // glCheck();

        // Define Attribute Sets
        // DOC: glVertexAttribPointer(index, size, type, normalized, stride (offset between 2 attributes), offset);
        glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, VertexData.sizeof, cast(void*)(0 * float.sizeof));  // x, y, z
        glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, VertexData.sizeof, cast(void*)(3 * float.sizeof));  // x, y, z
        glVertexAttribPointer(2, 4, GL_FLOAT, GL_FALSE, VertexData.sizeof, cast(void*)(7 * float.sizeof));  // r, g, b, a
        glVertexAttribPointer(3, 2, GL_FLOAT, GL_FALSE, VertexData.sizeof, cast(void*)(10 * float.sizeof));  // s, t
        glCheck();

        // Disable Attribute Sets
        // glDisableVertexAttribArray(0);
        // glDisableVertexAttribArray(1);
        // glDisableVertexAttribArray(2);
        glCheck();

        // Clean up context
        glBindVertexArray(0);
        glCheck();

        glBindBuffer(GL_ARRAY_BUFFER, 0);
        glCheck();
    }

    @property VertexData[] vertices() {
        return this._vertices;
    }

    @property void vertices(VertexData[] vertices) {
        this._vertices = vertices;
        this.updateVertices();
    }
    
    /**
     * Sends the vertice data to the GPU. It is then accessible via
     * rawVertexArrayHandle.
     */
    void updateVertices() {
        glBindVertexArray(this._vao);
        glBindBuffer(GL_ARRAY_BUFFER, this._vertexBuffer);
        glCheck();

        this._vertexCount = this._vertices.length;
        glBufferData(GL_ARRAY_BUFFER, this._vertices.length * VertexData.sizeof, this._vertices.ptr, GL_STATIC_DRAW);
        glCheck();

        glBindVertexArray(0);
        glBindBuffer(GL_ARRAY_BUFFER, 0);
        glCheck();
    }
    
    ///if indices are set, it uses glDrawElements instead of glDrawArrays
    void setIndices(IndexData[] indices) {
        this._shaderProgram.attach();

        glBindVertexArray(this._vao);
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, this._indexBuffer);
        glCheck();
        
        this._indexCount = indices.length;
        glBufferData(GL_ELEMENT_ARRAY_BUFFER, indices.length * IndexData.sizeof, indices.ptr, GL_STATIC_DRAW);
        glCheck();
        
        glBindVertexArray(0);
        glBindBuffer(GL_ARRAY_BUFFER, 0);
        glCheck();

        this._shaderProgram.detach();
    }

    void render(ShaderProgram shader, Matrix4 modelMatrix, Matrix4 viewMatrix, Matrix4 projectionMatrix) {
        if(shader is null) {
            shader = ShaderProgram.defaultPipeline;
        }
        shader.attach();

        glBindVertexArray(this._vao); // is the vertex buffer object connected to the vertex array obkect?
        glBindBuffer(GL_ARRAY_BUFFER, this._vertexBuffer);
        glCheck();

        // Enable Attribute Sets
        glEnableVertexAttribArray(0);
        glEnableVertexAttribArray(1);
        glEnableVertexAttribArray(2);
        glCheck();

        // glDisable(GL_LIGHTING);
        // glDisable(GL_DEPTH_TEST);
        // glDisable(GL_ALPHA_TEST);
        // glEnable(GL_TEXTURE_2D);
        // glEnable(GL_BLEND);
        glCheck();

        //Send matrices to shader
        //~ writeln("modelMatrix: ", modelMatrix);
        //~ writeln("viewMatrix: ", viewMatrix);
        //~ writeln("projectionMatrix: ", projectionMatrix);
        shader.sendUniform("uModelMatrix", modelMatrix);
        shader.sendUniform("uViewMatrix", viewMatrix);
        shader.sendUniform("uProjectionMatrix", projectionMatrix);
        
        // Draw
        if(this._indexCount > 0) {
            glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, this._indexBuffer); 
            glDrawElements(GL_TRIANGLES, cast(int)this._indexCount, GL_UNSIGNED_INT, null);
        }
        else {
            glDrawArrays(GL_TRIANGLES, 0, cast(int)this._vertexCount);
        }
        glCheck();

        // Disable Attribute Sets
        //glDisableVertexAttribArray(0);
        //glDisableVertexAttribArray(1);
        //glDisableVertexAttribArray(2);
        glCheck();

        // Unbind
        glBindBuffer(GL_ARRAY_BUFFER, 0);
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0); 
        glBindVertexArray(0);
        glCheck();
    }
}
