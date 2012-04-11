/**
 * Manages cameras and viewports.
 */

module derp.graphics.view;

import std.algorithm;
import std.string;
import std.conv;

import derp.core.geo;

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
