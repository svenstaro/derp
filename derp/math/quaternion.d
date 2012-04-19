module derp.math.quaternion;

import derp.math.all;

public import gl3n.linalg : quat;

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
