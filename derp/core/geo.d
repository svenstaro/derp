/**
 * Provides vectors, matrices, quaternions and other stuctures for
 * geometric data.
 */
module derp.core.geo;

import derp.math.all;
import std.traits;


struct Rect {
    Vector2 pos;
    Vector2 size;

    this(Vector2 pos, Vector2 size) @safe nothrow {
        this.pos = pos;
        this.size = size;
    }

    this(float x = 0, float y = 0, float w = 0, float h = 0) @safe nothrow {
        this.pos = Vector2(x, y);
        this.size = Vector2(w, h);
    }

    @property float left() @safe nothrow { return this.pos.x; }
    @property float right() @safe nothrow { return this.pos.x + this.size.x; }
    @property float top() @safe nothrow { return this.pos.y; }
    @property float bottom() @safe nothrow { return this.pos.y + this.size.y; }
}


struct Ray {
    Vector3 origin;
    Vector3 direction;

    Vector3 pointAtDistance(float distance) {
        return this.origin + this.direction * distance;
    }

    Vector3 opBinary(string op : "*")(float distance) {
        return this.pointAtDistance(distance);
    }
}

struct Plane {
    Vector3 normal;
    float distance;
}

struct Sphere {
    Vector3 center;
    float radius;

    bool contains(Vector3 point) {
        return distance(this.center, point) <= this.radius;
    }
}

struct Triangle {
    Vector3[3] vertices;

    @property Vector3 normal() {
        Vector3 u = this.vertices[1] - this.vertices[0];
        Vector3 v = this.vertices[2] - this.vertices[0];
        return cross(u, v);
    }
}

struct Triangle2 {
    Vector2[3] vertices;
    
    this(Vector2 a, Vector2 b, Vector2 c) {
        this.vertices = [a, b, c];
    }

    bool containsPoint(Vector2 point) {
        bool sameSide(Vector3 p1, Vector3 p2, Vector3 a, Vector3 b) {
            Vector3 cp1 = cross(b - a, p1 - a);
            Vector3 cp2 = cross(b - a, p2 - a);
            return dot(cp1, cp2) >= 0;
        }

        Vector3 v0 = Vector3(this.vertices[0].x, this.vertices[0].y, 0);
        Vector3 v1 = Vector3(this.vertices[1].x, this.vertices[1].y, 0);
        Vector3 v2 = Vector3(this.vertices[2].x, this.vertices[2].y, 0);
        Vector3 p = Vector3(point.x, point.y, 0);

        return
            sameSide(p, v0, v1, v2) &&
            sameSide(p, v1, v2, v0) &&
            sameSide(p, v2, v0, v1);
    }
}

/// TODO
struct Box {
    Vector3 center;
    Vector3 extends;
}

/// TODO
struct Frustum {
}

// TODO: intersection

