/**
 * Manages cameras and viewports.
 */

module derp.graphics.camera;

import std.stdio;
import std.math;
import std.algorithm;

import derp.math.all;
import derp.core.geo;
import derp.core.scene;
import derp.graphics.view;
import derp.graphics.render;


/**
 * CameraComponent
 */
class CameraComponent : Component {
public:
    enum ProjectionMode {
        Perspective,
        Orthographic
    }

private:
    Matrix4 _projectionMatrix;
    Matrix4 _cachedViewMatrix;

    // Cached stuff for perspective mode (so we can get and modify the values)
    Angle _fieldOfView = degrees(60); // in y-axis
    float _aspectRatio = 1; // w / h

    ProjectionMode _projectionMode;
    Rect _viewBounds;
    float _nearClipDistance = 1;
    float _farClipDistance = 1000;

    bool _needProjectionUpdate = true;

public:
    Viewport[] connectedViewports;

    /// Default constructor (uses perspective mode at 60° FOV with an AR of 1:1)
    this(string name) @safe nothrow {
        this(name, degrees(60), 1.0);
    }

    /// Constructor with perspective projection.
    this(string name, Angle fov, float aspectRatio) @safe nothrow {
        super(name);
        this.projectionMode = ProjectionMode.Perspective;
        this.fieldOfView = fov;
        this.aspectRatio = aspectRatio;
    }

    /// Constructor with orthographic projection.
    this(string name, Rect bounds) @safe nothrow {
        super(name);
        this.projectionMode = ProjectionMode.Orthographic;
        this.orthographicBounds = bounds;
    }

    @property ProjectionMode projectionMode() @safe nothrow {
        return this._projectionMode;
    }

    @property void projectionMode(ProjectionMode projectionMode) @safe nothrow {
        this._projectionMode = projectionMode;
        this._needProjectionUpdate = true;
    }

    @property float nearClipDistance() @safe nothrow {
        return this._nearClipDistance;
    }

    @property void nearClipDistance(float nearClipDistance) @safe nothrow {
        this._nearClipDistance = nearClipDistance;
        this._needProjectionUpdate = true;
    }

    @property float farClipDistance() @safe nothrow {
        return this._farClipDistance;
    }

    @property void farClipDistance(float farClipDistance) @safe nothrow {
        this._farClipDistance = farClipDistance;
        this._needProjectionUpdate = true;
    }

    @property Angle fieldOfView() @safe nothrow {
        assert(this._projectionMode == ProjectionMode.Perspective, "Cannot use field of view setting in orthographic mode.");
        return this._fieldOfView;
    }

    @property void fieldOfView(Angle fieldOfView) @safe nothrow {
        assert(this._projectionMode == ProjectionMode.Perspective, "Cannot use field of view setting in orthographic mode.");
        this._fieldOfView = fieldOfView;
        this._needProjectionUpdate = true;
    }

    @property float aspectRatio() @safe nothrow {
        assert(this._projectionMode == ProjectionMode.Perspective, "No need to use aspect ratio setting in orthographic mode.");
        return this._aspectRatio;
    }

    /**
     * Sets the aspect ratio to match the width and height of the target.
     *
     * Examples:
     * ---
     * makeAspectRatio(4, 3);       // 4:3
     * makeAspectRatio(16, 9);      // 16:9
     * makeAspectRatio(16, 10);     // 16:10
     * makeAspectRatio(210, 297);   // DIN-Format
     * ---
     */
    void makeAspectRatio(float width, float height) @safe nothrow {
        this.aspectRatio = width / height;
    }

    @property void aspectRatio(float aspectRatio) @safe nothrow {
        assert(this._projectionMode == ProjectionMode.Perspective, "No need to use aspect ratio setting in orthographic mode.");
        this._aspectRatio = aspectRatio;
        this._needProjectionUpdate = true;
    }

    @property void orthographicBounds(Rect bounds) @safe nothrow {
        assert(this._projectionMode == ProjectionMode.Orthographic, "Cannot use orthographic bounds in perspective mode.");
        this._viewBounds = bounds;
        this._needProjectionUpdate = true;
        this._needUpdate = true;
    }

    @property const Rect orthographicBounds() @safe nothrow {
        assert(this._projectionMode == ProjectionMode.Orthographic, "Cannot use orthographic bounds in perspective mode.");
        return this._viewBounds;
    }

    /// Returns the projection matrix, cached.
    @property Matrix4 projectionMatrix() @safe nothrow {
        if(this._needProjectionUpdate) {
            this._updateProjectionMatrix();
            this._needProjectionUpdate = false;
        }
        return _projectionMatrix;
    }

    /// Return the view matrix, cached.
    @property Matrix4 viewMatrix() @safe nothrow {
        if(this._needUpdate) {
            auto pos = this.node.derivedPosition;
            if(this._projectionMode == ProjectionMode.Orthographic) {
                auto v = this._viewBounds;
                pos += Vector3(
                        -v.size.x / 2 - v.pos.x,
                        -v.size.y / 2 - v.pos.y,
                        0);
            }

            makeTransform(this._cachedViewMatrix, pos, Vector3(1,1,1), this.node.derivedOrientation);
            this._needUpdate = false;
        }
        return this._cachedViewMatrix;
    }

    /// Returns a Ray From ScreenPoint into the Scene
    Ray cameraToViewportRay(uint screenX, uint screenY) {
        Matrix4 inverseVP = this.projectionMatrix * this.viewMatrix.inverse();
        real nx = (2.0f * screenX) - 1.0f;
        real ny = 1.0f - (2.0f * screenY);
        Vector4 nearPoint = Vector4(nx, ny, -1.0f, 0.0f);
        Vector4 midPoint = Vector4(nx, ny, 0.0f, 0.0f);
        Ray ray;
        ray.origin = Vector3((inverseVP * nearPoint).xyz);
        ray.direction = Vector3((inverseVP * midPoint).xyz) - ray.origin;
        ray.direction.normalize();
        return ray;
    }

    /// Renders the scene for the Viewport `viewport`.
    void render(Viewport viewport) {
        assert(this.node !is null, "Camera needs to be attached to a Node to render a scene.");

        RenderQueue queue = new RenderQueue(this, viewport);
        this.node.rootNode.prepareRender(queue); // fill the queue
        queue.renderAll();
    }

private:
    void _updatePerspective() @safe nothrow {
        // Calculate size of the near plane (part of the view frustum)
        float height = this._nearClipDistance * tan(this._fieldOfView.radians / 2);
        float width = height * this._aspectRatio;
        this._viewBounds = Rect(- width, -height, 2*width, 2*height);
    }

    void _updateProjectionMatrix() @trusted nothrow {
        assert(this._farClipDistance >= this._nearClipDistance, "Far clip distance cannot be smaller than near clip distance.");

        // NOTICE: Parameters for Matrix.orthographic and Matrix.perspective are
        // float left, float right, float bottom, float top, float near, float far

        if(this._projectionMode == ProjectionMode.Orthographic) {
            this._projectionMatrix = Matrix4.orthographic(
                this._viewBounds.left, this._viewBounds.right,
                this._viewBounds.bottom, this._viewBounds.top,
                this._nearClipDistance, this._farClipDistance);
            float x = this._viewBounds.size.x / 2;
            float y = this._viewBounds.size.y / 2;
            this._projectionMatrix = Matrix4.orthographic(-x, x, y, -y, this._nearClipDistance, this._farClipDistance);
        } else {
            this._updatePerspective();
            try{
            this._viewBounds.writeln("viewBounds");}catch(Exception e){}
            this._projectionMatrix = Matrix4.perspective(
                this._viewBounds.left, this._viewBounds.right,
                this._viewBounds.bottom, this._viewBounds.top,
                this._nearClipDistance, this._farClipDistance);
        }
    }
}
