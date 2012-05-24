module derp.graphics.vertexbuffer;

import std.stdio;

import derelict.opengl3.gl3;
import derelict.glfw3.glfw3;

import derp.math.all;
import derp.graphics.util;
import derp.graphics.shader;
import derp.graphics.draw;

struct VertexData {
    float x, y, z, r, g, b, a, s, t;

    this(float x = 0, float y = 0, float z = 0, float r = 0, float g = 0, float b = 0, float a = 1, float s = 0, float t = 0) {
        this.x = x;
        this.y = y;
        this.z = z;
        this.r = r;
        this.g = g;
        this.b = b;
        this.a = a;
        this.s = s;
        this.t = t;
    }
}

/**
 * Renders a single Quad.
 */
class VertexBufferObject {
private:
    VertexData[] _vertices;

public:	
    uint array; // vertex buffer object, keeps track of vertex attributes etc.
    uint buffer;
    ulong vertexCount;

    this() {
        create();
    }

    void create() {
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
        glCheck();

        // glBindAttribLocation(this.shaderProgram.handle, 0, "_vertex");
        // glBindAttribLocation(this.shaderProgram.handle, 1, "_color");
        // glBindAttribLocation(this.shaderProgram.handle, 2, "_texCoord");
        // glCheck();

        // Define Attribute Sets
        // DOC: glVertexAttribPointer(index, size, type, normalized, stride (offset between 2 attributes), offset);
        glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, VertexData.sizeof, cast(void*)(0 * float.sizeof));  // x, y, z
        glVertexAttribPointer(1, 4, GL_FLOAT, GL_FALSE, VertexData.sizeof, cast(void*)(3 * float.sizeof));  // r, g, b, a
        glVertexAttribPointer(2, 2, GL_FLOAT, GL_FALSE, VertexData.sizeof, cast(void*)(7 * float.sizeof));  // s, t
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
        glBindVertexArray(array);
        glBindBuffer(GL_ARRAY_BUFFER, buffer);
        glCheck();

        this.vertexCount = this._vertices.length;
        glBufferData(GL_ARRAY_BUFFER, this._vertices.length * VertexData.sizeof, this._vertices.ptr, GL_STATIC_DRAW);
        glCheck();

        glBindVertexArray(0);
        glBindBuffer(GL_ARRAY_BUFFER, 0);
        glCheck();
    }

    void render(ShaderProgram shader, Matrix4 modelMatrix, Matrix4 viewMatrix, Matrix4 projectionMatrix) {
        if(shader is null) {
            shader = ShaderProgram.defaultPipeline;
        }
        shader.attach();

        glBindVertexArray(array); // is the vertex buffer object connected to the vertex array obkect?
        glBindBuffer(GL_ARRAY_BUFFER, buffer);
        glCheck();

        // Enable Attribute Sets
        glEnableVertexAttribArray(0);
        glEnableVertexAttribArray(1);
        glEnableVertexAttribArray(2);
        glCheck();

        // glDisable(GL_LIGHTING);
        glDisable(GL_DEPTH_TEST);
        // glDisable(GL_ALPHA_TEST);
        // glEnable(GL_TEXTURE_2D);
        // glEnable(GL_BLEND);
        glCheck();

        //Send matrices to shader
        shader.sendUniform("uModelMatrix", modelMatrix);
        shader.sendUniform("uViewMatrix", viewMatrix);
        shader.sendUniform("uProjectionMatrix", projectionMatrix);
        
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
    }
}
