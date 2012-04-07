/**
 * Manages cameras and viewports.
 */

module derp.graphics.view;

import std.algorithm;
import std.string;
import std.conv;

/**
 * A camera in 3D space.
 */
class Camera {
    Viewport[] connectedViewports;
    void connectViewport(Viewport viewport) {
        viewport.setCurrentCamera(this);
    }
}

/**
 * A viewport represents a part of a surface in which to render.
 */
class Viewport {
    Camera currentCamera = null;

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
}

/**
 * A 2D viewport does not require a Camera, instead it creates its own
 * OpenGL camera and renders in orthographic projection mode.
 *
 * The Viewport2D class supports pixel-perfect rendering.
 */
class Viewport2D : Viewport {

}
