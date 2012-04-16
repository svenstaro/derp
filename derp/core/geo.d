/**
 * Provides vectors, matrices, quaternions and other stuctures for
 * geometric data.
 */

module derp.core.geo;

public import gl3n.linalg; // let everyone access vec2 etc.
import std.math;

alias vec2 Vector2;
alias vec3 Vector3;
alias vec4 Vector4;
alias vec2i Vector2i;
alias vec3i Vector3i;
alias vec4i Vector4i;
alias mat2 Matrix2;
alias mat3 Matrix3;
alias mat34 Matrix34;
alias mat4 Matrix4;
alias quat Quaternion;

struct Angle {
private:
    float _asRadians;
public:
    @property float radians() {
        return this._asRadians;
    }

    @property float radians(float radians) {
        this._asRadians = radians;
        return this._asRadians;
    }

    @property float degrees() {
        return this._asRadians * 180.0 / PI;
    }

    @property float degrees(float degrees) {
        this._asRadians = degrees * PI / 180.0;
        return degrees;
    }

    Angle opBinary(string op, T)(T inp) const if((op == "*") || (op == "/")) {
        Angle ret;
        mixin("ret.radians = this.radians " ~ op ~ " inp.radians;");
        return ret;
    }

    Angle opBinaryRight(string op, T)(T inp) const if((op == "*") || (op == "/")) {
        return this.opBinary!(op)(inp);
    }
}

Angle radians(float radians) {
    Angle a;
    a.radians = radians;
    return a;
}

Angle degrees(float degrees) {
    Angle a;
    a.degrees = degrees;
    return a;
}

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

// TODO: intersections
