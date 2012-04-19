module derp.math.angle;

import std.math;
import std.traits;

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
