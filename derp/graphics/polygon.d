module derp.graphics.polygon;

import std.stdio;
import std.algorithm;

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

class PolygonComponent : Component, Renderable {
protected:
    Color _color = Color(1, 1, 1);
    bool _needsUpdate = true;
    VertexBufferObject _vbo;
    Vector2[] _points;

    // TODO: border width, border color

public:
    this(string name, ShaderProgram shader = null) {
        super(name);
        this._vbo = new VertexBufferObject(shader);
        this.clearPoints();
    }

    void _updateVertices() {
        Vector2[] vertices = new Vector2[this._points.length];
        vertices[] = this._points;
        Triangle2[] triangles;

        while(vertices.length >= 3) {
            // find an ear
            int i = 0;
            Triangle2 ear;
            while(i < vertices.length) {
                ear = Triangle2(vertices[i <= 0 ? vertices.length - 1 : i - 1],
                        vertices[i],
                        vertices[i+1 >= vertices.length ? 0 : i + 1]
                        );
                i++;
                bool contains = false;
                foreach(point; vertices) {
                    if(point != ear.vertices[0] && point != ear.vertices[1] && point != ear.vertices[2] && ear.containsPoint(point)) {
                        contains = true;
                    }
                }
                if(!contains) break;
            }
            if(i == vertices.length) {
                return; // did not find a tip, die silently
            }

            // add ear as triangle
            triangles ~= ear;

            // remove ear tip point
            vertices = std.algorithm.remove(vertices, i - 1);
        }

        VertexData[] v;
        foreach(t; triangles) {
            for(int x = 0; x < 3; ++x) {
                v ~= VertexData(t.vertices[x].x, t.vertices[x].y, 0, 
                        this._color.r, this._color.g, this._color.b, this._color.a,
                        0, 0);
            }
        }

        this._vbo.setVertices(v);
        this._needsUpdate = false;
    }
    
    void prepareRender(RenderQueue queue) {
        queue.push(this);
    }

    void render(RenderQueue queue) {
        if(this._needsUpdate) {
            this._updateVertices();
        }

        glEnable(GL_BLEND);
        glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        
        this._vbo.shaderProgram.attach();
        this._vbo.shaderProgram.setTexture(Texture.empty, "uTexture0", 0);
        this._vbo.render(this.node.derivedMatrix, queue.camera.viewMatrix, queue.camera.projectionMatrix);
    }

    void setPoints(Vector2[] points) {
        this._points = points;
        this._needUpdate = true;
    }

    void addPoint(Vector2 point) {
        this._points ~= point;
        this._needUpdate = true;
    }

    void clearPoints() {
        this.setPoints([]);
    }

    Vector2[] getPoints() {
        return this._points;
    }


    @property Vector2[] points() {
        return this._points;
    }

    @property Color color() {
        return this._color;
    }

    @property void color(Color color) {
        this._color = color;
        this._needsUpdate = true;    
    }
}

Vector2[] rectangle(float x, float y, float w, float h) {
    Vector2[] r = new Vector2[4];
    r[0] = Vector2(x, y);
    r[1] = Vector2(x + w, y);
    r[2] = Vector2(x + w, y + h);
    r[3] = Vector2(x, y + h);
    return r;
}

Vector2[] circle(Vector2 position, float radius, float resolution = 16) {
    Vector2[] v;
    for(float a = 0; a < 1; a += 1.0 / resolution) {
        auto an = degrees(a * 360);
        v ~= Vector2(position.x + sin(an.radians) * radius, 
                position.y + cos(an.radians) * radius);
    }
    return v;
}
