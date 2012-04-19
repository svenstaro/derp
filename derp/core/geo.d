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

    this(Vector2 pos, Vector2 size) {
        this.pos = pos;
        this.size = size;
    }

    this(float x = 0, float y = 0, float w = 0, float h = 0) {
        this.pos = Vector2(x, y);
        this.size = Vector2(w, h);
    }
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

/// TODO
struct Box {
    Vector3 center;
    Vector3 extends;
}

/// TODO
struct Frustum {
}

// TODO: intersection

