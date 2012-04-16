/**
 * Provides vectors, matrices, quaternions and other stuctures for
 * geometric data.
 */

module derp.core.geo;

public import gl3n.linalg; // let everyone access vec2 etc.
import std.math;
import std.traits;

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

@property Vector3 xAxis(in Quaternion q) @safe nothrow {
    real ty = 2.0f*q.y;
    real tz = 2.0f*q.z;
    real twy = ty*q.w;
    real twz = tz*q.w;
    real txy = ty*q.x;
    real txz = tz*q.x;
    real tyy = ty*q.y;
    real tzz = tz*q.z;
    return Vector3(1.0f-(tyy+tzz), txy+twz, txz-twy);
}

@property Vector3 yAxis(in Quaternion q) @safe nothrow {
    real tx = 2.0f*q.x;
    real ty = 2.0f*q.y;
    real tz = 2.0f*q.z;
    real twx = tx*q.w;
    real twz = tz*q.w;
    real txx = tx*q.x;
    real txy = ty*q.x;
    real tyz = tz*q.y;
    real tzz = tz*q.z;
    return Vector3(txy-twz, 1.0f-(txx-tzz), tyz+twx);
}

@property Vector3 zAxis(in Quaternion q) @safe nothrow {
    real tx = 2.0f*q.x;
    real ty = 2.0f*q.y;
    real tz = 2.0f*q.z;
    real twx = ty*q.w;
    real twy = tz*q.w;
    real txx = ty*q.x;
    real txz = tz*q.x;
    real tyy = ty*q.y;
    real tyz = tz*q.z;
    return Vector3(txz+twy, tyz-twx, 1.0f-(txx+tyy));
}

void fromAngleAxis(ref Quaternion q, in Angle angle, in Vector3 axis) @safe nothrow {
    float degree = angle.degrees;
    degree /= 2;
    auto s = sin(degree);
    q.w = cos(degree);
    q.x = s*axis.x;
    q.y = s*axis.y;
    q.z = s*axis.z;
}

auto ref makeTransform(ref Matrix4 matrix, in Vector3 position, in Vector3 scale, in Quaternion orientation) @safe nothrow {
    // Ordering:
    //    1. Scale
    //    2. Rotate
    //    3. Translate

    Matrix3 rot3x3 = orientation.to_matrix!(3,3);

    // Set up final matrix with scale, rotation and translation
    matrix[0][0] = scale.x * rot3x3[0][0]; 
    matrix[0][1] = scale.x * rot3x3[0][1];
    matrix[0][2] = scale.x * rot3x3[0][2];
    matrix[1][0] = scale.y * rot3x3[1][0]; 
    matrix[1][1] = scale.y * rot3x3[1][1]; 
    matrix[1][2] = scale.y * rot3x3[1][2]; 
    matrix[2][0] = scale.z * rot3x3[2][0]; 
    matrix[2][1] = scale.z * rot3x3[2][1]; 
    matrix[2][2] = scale.z * rot3x3[2][2]; 
    matrix[3][0] = position.x; 
    matrix[3][1] = position.y; 
    matrix[3][2] = position.z;

    // No projection term
    matrix[0][3] = 0; 
    matrix[1][3] = 0; 
    matrix[2][3] = 0; 
    matrix[3][3] = 1;
    return matrix;
}



Quaternion rotationTo(in Vector3 src, in Vector3 dest, in Vector3 fallbackAxis = Vector3(0,0,0)) @safe nothrow
{
	// Based on Stan Melax's article in Game Programming Gems
	Quaternion q;
	// Copy, since cannot modify local
	Vector3 v0 = src;
	Vector3 v1 = dest;
	v0.normalize();
	v1.normalize();

	real d = dot(v0, v1);
	// If dot == 1, vectors are the same
	if (d >= 1.0f)
	{
		return Quaternion(0,0,0,1);
	}
	if (d < (1e-6f - 1.0f))
	{
		if (fallbackAxis != Vector3(0,0,0))
		{
			// rotate 180 degrees about the fallback axis
			fromAngleAxis(q, degrees(180), fallbackAxis);
		}
		else
		{
			// Generate an axis
			enum VX = Vector3(1,0,0);
			Vector3 axis = cross(VX, src);
			if (axis.length == 0) // pick another if colinear
				axis = cross(Vector3(0,1,0), src);
			axis.normalize();
			fromAngleAxis(q, degrees(180), axis);
		}
	}
	else
	{
		real s = sqrt( (1+d)*2 );
		real invs = 1 / s;

		Vector3 c = cross(v0, v1);

		q.x = c.x * invs;
		q.y = c.y * invs;
		q.z = c.z * invs;
		q.w = s * 0.5f;
		q.normalize();
	}
	return q;
}





struct Angle {
private:
    float _asRadians;
public:
    @property float radians() pure const @safe nothrow {
        return this._asRadians;
    }

    @property float radians(float radians) pure @safe nothrow {
        this._asRadians = radians;
        return this._asRadians;
    }

    @property float degrees() pure const @safe nothrow {
        return this._asRadians * 180.0 / PI;
    }

    @property float degrees(float degrees) pure @safe nothrow {
        this._asRadians = degrees * PI / 180.0;
        return degrees;
    }

    /// opBinary
    Angle opBinary(string op, T)(T inp) pure const @safe nothrow {
        Angle ret = this;
        mixin("ret "~op~"= inp;");
        return ret;
    }
    
    /// opOpAssign a numeric type
    auto ref opOpAssign(string op, T)(T inp) pure @safe nothrow
    if(isNumeric!T &&((op == "*") || (op == "/"))) {
        mixin ("this._asRadians "~op~"= inp;");
        return this;
    }
    
    /// opOpAssign an Angle
    auto ref opOpAssign(string op)(Angle inp) pure @safe nothrow
    if(op == "*" || op == "/") {
        mixin ("this._asRadians "~op~"= inp.radians;");
        return this;
    }

    Angle opBinaryRight(string op, T)(T inp) pure const @safe nothrow
    if((op == "*") || (op == "/")) {
        return this.opBinary!(op)(inp);
    }
}

Angle radians(float radians) pure @safe nothrow {
    Angle a;
    a.radians = radians;
    return a;
}

Angle degrees(float degrees) pure @safe nothrow {
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
