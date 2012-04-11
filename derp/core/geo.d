/**
 * Provides vectors, matrices, quaternions and other stuctures for
 * geometric data.
 */

module derp.core.geo;

public import gl3n.linalg; // let everyone access vec2 etc.

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
alias mat4 ProjectionMatrix;
alias quat Quaternion;

