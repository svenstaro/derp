/**
 * Manages cameras and viewports.
 */

module derp.graphics.view;

import std.algorithm;
import std.string;
import std.conv;

import derp.core.geo;
import derp.graphics.camera;

/**
 * A viewport represents a part of a surface in which to render.
 */
class Viewport {
    CameraComponent currentCamera = null;
    Rect bounds;

    this(CameraComponent camera = null) {
        this.setCurrentCamera(camera);
    }

    void setCurrentCamera(CameraComponent camera) {
        if(this.currentCamera) {
            // This viewport is already connected to a camera, remove it from its viewports list.
            remove(this.currentCamera.connectedViewports, indexOf(this.currentCamera.connectedViewports, this));
        }
        if(camera) {
            camera.connectedViewports ~= this;
        }
        this.currentCamera = camera;
    }
    
    void render() {
        assert(this.currentCamera !is null, "Viewport needs a camera to render");
        this.currentCamera.render(this);
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
        this.setCurrentCamera(new CameraComponent("defaultCamera", degrees(80), 1, 1, 100));
    }

    void centerAt(Vector2 center) {
        this.offset = this.internalSize * 0.5 - center;
    }

}
