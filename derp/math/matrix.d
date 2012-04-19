module derp.math.matrix;

import derp.math.all;

public import gl3n.linalg : Matrix2=mat2, Matrix3=mat3, MAtrix34=mat34,Matrix4=mat4;
public import gl3n.util : isMatrix = is_matrix;

//~ alias mat2 Matrix2;
//~ alias mat3 Matrix3;
//~ alias mat34 Matrix34;
//~ alias mat4 Matrix4;


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
