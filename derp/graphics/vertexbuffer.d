module derp.graphics.vertexbuffer;

import std.stdio;

import derelict.opengl3.gl3;
import derelict.glfw3.glfw3;

import derp.math.all;
import derp.graphics.util;
import derp.graphics.shader;
import derp.graphics.draw;


struct VertexData {
    float x, y, z, nx, ny, nz, r, g, b, a, s, t;

    this(float x = 0, float y = 0, float z = 0, float nx = 0, float ny = 0, float nz = 0, float r = 0, float g = 0, float b = 0, float a = 1, float s = 0, float t = 0) {
        this.x = x;
        this.y = y;
        this.z = z;
        this.nx = nx;
        this.ny = ny;
        this.nz = nz;
        this.r = r;
        this.g = g;
        this.b = b;
        this.a = a;
        this.s = s;
        this.t = t;
    }
}

class Vertex {
public:
    Vector3 pos;
    Vector3 n;
    Vector2 uv;

    this(Vector3 pos, Vector3 normal = Vector3(), Vector2 uv = Vector2()) {
        this.pos = pos;
        this.n = normal;
        this.uv = uv;
    }

    VertexData toVertexData(Color color = Color.White) {
        return VertexData(this.pos.x, this.pos.y, this.pos.z,
                this.n.x, this.n.y, this.n.z,
                color.r, color.g, color.b, color.a,
                this.uv.x, this.uv.y);
    }
}


/**
 * Renders a single Quad.
 */
class VertexBufferObject {
private:
    ShaderProgram _shaderProgram;
    VertexData[] _vertices;

public:	
    uint array; // vertex buffer object, keeps track of vertex attributes etc.
    uint buffer;
    ulong vertexCount;

    this(ShaderProgram shaderProgram = null) {
        this._shaderProgram = shaderProgram is null ? 
            ShaderProgram.defaultPipeline : shaderProgram;
        create();
    }

    @property void shaderProgram(ShaderProgram shaderProgram) {
        if(this._shaderProgram == shaderProgram) return;

        this._shaderProgram = shaderProgram;
        this.create(); // update shader properties
        this.setVertices(this._vertices); // update vertex buffer
    }

    @property ShaderProgram shaderProgram() {
        return this._shaderProgram;
    }

    void create() {
        // bind texture
        this._shaderProgram.attach();

        // Create VBO
        glGenVertexArrays(1, &array);
        glCheck();
        glBindVertexArray(array);
        glCheck();

        // Create the buffer
        glGenBuffers(1, &buffer);
        glCheck();

        // Set the buffer's vertex attributes
        glBindBuffer(GL_ARRAY_BUFFER, buffer);
        glCheck();
        glEnableVertexAttribArray(0);
        glEnableVertexAttribArray(1);
        glEnableVertexAttribArray(2);
        glEnableVertexAttribArray(3);
        glCheck();

        // glBindAttribLocation(this._shaderProgram.handle, 0, "_vertex");
        // glBindAttribLocation(this._shaderProgram.handle, 1, "_color");
        // glBindAttribLocation(this._shaderProgram.handle, 2, "_texCoord");
        // glCheck();

        // Define Attribute Sets
        // DOC: glVertexAttribPointer(index, size, type, normalized, stride (offset between 2 attributes), offset);

        // pos norm col uv

        glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, VertexData.sizeof, cast(void*)( 0 * float.sizeof));  // x, y, z
        glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, VertexData.sizeof, cast(void*)( 3 * float.sizeof));  // nx, ny, nz
        glVertexAttribPointer(2, 4, GL_FLOAT, GL_FALSE, VertexData.sizeof, cast(void*)( 6 * float.sizeof));  // r, g, b, a
        glVertexAttribPointer(3, 2, GL_FLOAT, GL_FALSE, VertexData.sizeof, cast(void*)(10 * float.sizeof));  // s, t
        glCheck();

        // Setup buffer
        // this.setVertexArray([]);

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
        this._shaderProgram.detach();
    }

    /**
     * Sends the vertice data to the GPU. It is then accessible via
     * rawVertexArrayHandle.
     */
    void setVertices(VertexData[] vertices) {
        this._vertices = vertices;
        
        // update the vertex buffer
        this._shaderProgram.attach();

        glBindVertexArray(array);
        glBindBuffer(GL_ARRAY_BUFFER, buffer);
        glCheck();

        this.vertexCount = this._vertices.length;
        glBufferData(GL_ARRAY_BUFFER, this.vertexCount * VertexData.sizeof, this._vertices.ptr, GL_STATIC_DRAW);
        glCheck();

        glBindVertexArray(0);
        glBindBuffer(GL_ARRAY_BUFFER, 0);
        glCheck();

        this._shaderProgram.detach();
    }

    void render(Matrix4 modelMatrix, Matrix4 viewMatrix, Matrix4 projectionMatrix) {
        // attach texture
        this._shaderProgram.attach();

        glBindVertexArray(array); // is the vertex buffer object connected to the vertex array obkect?
        glBindBuffer(GL_ARRAY_BUFFER, buffer);
        glCheck();

        // Enable Attribute Sets
        glEnableVertexAttribArray(0);
        glEnableVertexAttribArray(1);
        glEnableVertexAttribArray(2);
        glEnableVertexAttribArray(3);
        glCheck();

        // glDisable(GL_LIGHTING);
        // glDisable(GL_DEPTH_TEST);
        // glDisable(GL_ALPHA_TEST);
        // glEnable(GL_TEXTURE_2D);
        // glEnable(GL_BLEND);
        glCheck();

        //Send matrices to shader
        this._shaderProgram.sendUniform("uModelMatrix", modelMatrix);
        this._shaderProgram.sendUniform("uViewMatrix", viewMatrix);
        this._shaderProgram.sendUniform("uProjectionMatrix", projectionMatrix);
        
        // Draw
        glDrawArrays(GL_TRIANGLES, 0, cast(int) this.vertexCount);
        glCheck();

        // Disable Attribute Sets
        //glDisableVertexAttribArray(0);
        //glDisableVertexAttribArray(1);
        //glDisableVertexAttribArray(2);
        glCheck();

        // Unbind
        glBindVertexArray(0);
        glBindBuffer(GL_ARRAY_BUFFER, 0);
        glCheck();

        this._shaderProgram.detach();
        // detach texture
    }
}
