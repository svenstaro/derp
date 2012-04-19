/**
Module wrapping all math stuff, so we are able to replace gl3n at some point.
*/
module derp.math.all;

import std.traits;

public import std.math;
public import gl3n.linalg;
public import gl3n.util : isVector = is_vector, isMatrix = is_matrix;



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
    return Vector3(q.to_matrix!(3,3).matrix[0]);
}

@property Vector3 yAxis(in Quaternion q) @safe nothrow {
    return Vector3(q.to_matrix!(3,3).matrix[1]);
}

@property Vector3 zAxis(in Quaternion q) @safe nothrow {
    return Vector3(q.to_matrix!(3,3).matrix[2]);
}

void toAxis(in Quaternion q, out Vector3 xAxis, out Vector3 yAxis, out Vector3 zAxis) @safe nothrow {
    Matrix3 rotationMatrix = q.to_matrix!(3,3);
    xAxis = Vector3(rotationMatrix.matrix[0]);
    yAxis = Vector3(rotationMatrix.matrix[1]);
    zAxis = Vector3(rotationMatrix.matrix[2]);
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
        return Quaternion(1,0,0,0);
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
