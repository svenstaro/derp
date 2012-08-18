/**
 * Provides basic geometric Shapes
 */
module derp.core.shapes;

import derp.math.all;
import std.traits;


///2-Dimensional Rect
struct Rect2 {
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

///2-Dimensional LineSegment
struct LineSegment2 {
    Vector2 begin, end;
}

///3-Dimensional LineSegment
struct LineSegment {
    Vector3 begin, end;
}

///2-Dimensional Triangle
struct Triangle2 {
    Vector2[3] vertices;
    
    @property float area() pure const nothrow {
        return signedArea().abs();
    }
    
    @property float signedArea() pure const nothrow {
        alias this.vertices v;
        return (  ( v[1].x * v[0].y - v[0].x * v[1].y)
                + ( v[2].x * v[1].y - v[1].x * v[2].y)
                + ( v[0].x * v[2].y - v[2].x * v[0].y)) 
                / 2;
    }
}

///3-Dimensional Triangle
struct Triangle {
    Vector3[3] vertices;
    
    @property Vector3 normal() pure const nothrow{
        Vector3 u = this.vertices[1] - this.vertices[0];
        Vector3 v = this.vertices[2] - this.vertices[0];
        return cross(u, v);
    }
}

///3-Dmensional Ray
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

///3-Dimensional Plane
struct Plane(int D, T) if (D > 0) {
    Vector3 normal;
    float distance;
}

///3-Dimensional Sphere
struct Sphere {
    Vector3 center;
    float radius;
}

/// Does Sphere s1 contain Sphere s2
bool contains(in Sphere s1, in Sphere s2) pure @safe nothrow {
    if (s2.radius > s1.radius)
        return false;
    float innerRadius = s1.radius - s2.radius;
    return distance(s1.center, s2.center) < innerRadius;
}

/// Does Sphere s1 contain Point point
bool contains(in Sphere s, Vector3 point) pure @safe nothrow {
    return distance(s.center, point) <= s.radius;
}

/// Does Sphere s1 touch Sphere s2
bool touches(in Sphere s1, in Sphere s2) pure @safe nothrow {
    float outerRadius = s1.radius + s2.radius;
    return distance(s1.center, s2.center) < outerRadius;
}

/// TODO:
struct Box {
    Vector3 center;
    Vector3 extends;
}

/// TODO:
struct Frustum {
}


/// Axis-aligned 2D ellipsis.
struct AAEllipse2(T) {
    float a, b;

    this(T a, T b) {
        assert(a >= b);
        this.a = a;
        this.b = b;
    }

    float area() pure const {
        return PI * a * b;
    }
}

