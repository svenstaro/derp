/**
 * Viewports.
 */

module derp.graphics.view;

import std.algorithm;
import std.string;
import std.conv;

import derp.math.all;
import derp.core.geo;
import derp.graphics.camera;
import derp.graphics.window;

/**
 * A viewport represents a part of a surface in which to render.
 */
class Viewport {
public:
    Rect bounds;

private:
    CameraComponent _currentCamera = null;
    bool _allowChangeCamera = true;

public:
    this(CameraComponent camera = null, Rect bounds = Rect(0, 0, 100, 100)) {
        this.currentCamera = camera;
        this.bounds = bounds;
    }

    // width / height
    @property float aspectRatio() {
        return this.bounds.size.x / this.bounds.size.y;
    }

    @property void currentCamera(CameraComponent camera) {
        if(!this._allowChangeCamera) {
            throw new Exception("For this viewport the camera may not be changed.");
        }

        if(this._currentCamera) {
            // This viewport is already connected to a camera, remove it from its viewports list.
            remove(this._currentCamera.connectedViewports, countUntil(this._currentCamera.connectedViewports, this));
        }
        if(camera) {
            camera.connectedViewports ~= this;
        }
        this._currentCamera = camera;
    }

    @property CameraComponent currentCamera() {
        return this._currentCamera;
    }

    void render(Window window) {
        assert(this._currentCamera !is null, "Viewport needs a camera to render");
        window.setViewport(this.bounds);
        this._currentCamera.render(this);
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
    this(Rect bounds = Rect(0, 0, 100, 100)) {
        super(new CameraComponent("defaultCamera", bounds), bounds);
        this._allowChangeCamera = false; // forbid any further changes to the camera
    }

    void centerAt(Vector2 center) {
        // TODO
        // ?? this._offset = this._internalSize * 0.5 - center;
    }
}
