/**
 * Manages cameras and viewports.
 */

module derp.graphics.camera;

import std.math;
import std.stdio;

import derp.math.all;
import derp.core.geo;
import derp.core.scene;
import derp.graphics.view;
import derp.graphics.render;


/**
 * CameraComponent
 */
class CameraComponent : Component{
private:	
    Matrix4 _projectionMatrix;
    Matrix4 _cachedViewMatrix;
public:
    Viewport[] connectedViewports;
public:
    /// Constructor.
    this(string name, Angle fovY, float aspectRatio, float front, float back) @safe nothrow {
        super(name);
        setPerspective(fovY, aspectRatio, front, back);
    }

    /// ditto
    this(string name, float left, float right, float top, float bottom, float near, float far) @safe nothrow {
        super(name);
        setPerspective(left, right, top, bottom, near, far);
    }
    ///
    void setPerspective(Angle fovY, float aspectRatio, float front, float back) @safe nothrow {
        float tangent = tan((fovY/2).radians);   // tangent of half fovY
        float height = front * tangent;          // half height of near plane
        float width = height * aspectRatio;      // half width of near plane
        // params: left, right, bottom, top, near, far
        setPerspective(-width, width, -height, height, front, back);
    }	

    ///
    void setPerspective(float left, float right, float top, float bottom, float near, float far) @safe nothrow {		
        this._projectionMatrix = Matrix4.perspective(left, right, bottom, top, near, far);
    }
    
public:
    ///return projection matrix
    @property Matrix4 projectionMatrix() const @safe nothrow {
        return _projectionMatrix;
    }

    /// return cached view matrix. if nessacary, generate it
    @property Matrix4 viewMatrix() @safe nothrow {
        if(this._needUpdate)
        {
            makeTransform(this._cachedViewMatrix, this.node.position, Vector3(1,1,1), this.node.orientation);
            this._needUpdate = false;
        }
        return this._cachedViewMatrix;
    }
public:
    /// Returns a Ray From ScreenPoint into the Scene
    //~ Ray cameraToViewportRay(uint screenX, uint screenY) {
        //~ Matrix4 inverseVP = this.projectionMatrix * this.viewMatrix.inverse();
        //~ real nx = (2.0f * screenX) - 1.0f;
        //~ real ny = 1.0f - (2.0f * screenY);
        //~ Vector3 nearPoint = Vector3(nx, ny, -1.0f);
        //~ Vector3 midPoint = Vector3(nx, ny, 0.0f);
        //~ Ray ray;
        //~ ray.origin = inverseVP * nearPoint;
        //~ ray.direction = (inverseVP * midPoint) - ray.origin;
        //~ ray.direction.normalize();
        //~ return ray;
    //~ }

    /// Renders the scene for the Viewport `viewport`.
    void render(Viewport viewport) {
	writeln("camera.render");
        assert(this.node !is null, "Camera needs to be attached to a Node to render a scene.");

        RenderQueue queue = new RenderQueue(this, viewport);
        this.node.rootNode.prepareRender(queue); // fill the queue
        queue.renderAll();
    }
}
