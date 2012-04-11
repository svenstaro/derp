/**
 * Manages cameras and viewports.
 */

module derp.graphics.view;

import std.algorithm;
import std.string;
import std.conv;

public import gl3n.linalg; // let everyone access vec2 etc.

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

/**
 * A camera in 3D space.
 */
class Camera {
    Viewport[] connectedViewports;
    void connectViewport(Viewport viewport) {
        viewport.setCurrentCamera(this);
    }

    void update() {
        // set OpenGL camera mode
        // gluOrtho2D(0, 100, 0, 100);

    }
}

struct Rect {
    Vector2 pos;
    Vector2 size;

    this(float x = 0, float y = 0, float w = 0, float h = 0) {
        pos = Vector2(x, y);
        size = Vector2(w, h);
    }
}

/**
 * A viewport represents a part of a surface in which to render.
 */
class Viewport {
    Camera currentCamera = null;
    Rect bounds;

    this(Camera camera = null) {
        this.setCurrentCamera(camera);
    }

    void setCurrentCamera(Camera camera) {
        if(this.currentCamera) {
            // This viewport is already connected to a camera, remove it from its viewports list.
            remove(this.currentCamera.connectedViewports, indexOf(this.currentCamera.connectedViewports, this));
        }
        if(camera) {
            camera.connectedViewports ~= this;
        }
        this.currentCamera = camera;
    }

    void update() {
        // set OpenGL viewport

        // update the camera projection
        if(this.currentCamera) {
            this.currentCamera.update();
        }
    }
}

/**
 * A 2D viewport does not require a Camera, instead it creates its own
 * OpenGL camera and renders in orthographic projection mode.
 *
 * The Viewport2D class performs coordinate mapping, so one can either use
 * pixel coordinates (for pixel-perfect rendering) or other coordinate
 * systems.
 */
class Viewport2D : Viewport {
    Vector2 internalSize;
    Vector2 offset;

    this() {
        this.setCurrentCamera(new Camera());
    }

    void centerAt(Vector2 center) {
        this.offset = this.internalSize * 0.5 - center;
    }

    void updateCamera() {
        // set OpenGL camera projection
    }

    void update() {
        updateCamera();
        super.update();
    }
}
