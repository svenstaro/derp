/**
    Bugs: _parent Node has to become a weak referece, 
    else the GC might not free it. (double linked)
*/
module derp.core.scene;

import std.algorithm;
import std.math;

import derp.core.geo;

/// TransformSpace for Transformations
enum TransformSpace {
    Local,
    Parent,
    World
}

/***
    The Node class represents a Point in the Scene.
    It has a Position, Orientation and Scale.
    If any information of this node is requested, 
    it is recalculated if it is outdated.
*/
final class Node {
private:    
    Node[] _children;
    Component[] _components;
    Node _parent = null; //TODO: FIXME: this has to become a weak_reference!
    string _name;

private:
    Vector3 _localPosition;
    Quaternion _localOrientation;
    Vector3 _localScale;

    Vector3 _cachedDerivedPosition;
    Quaternion _cachedDerivedOrientation;
    Vector3 _cachedDerivedScale;

    Matrix4 _cachedMatrix;
    Matrix4 _cachedDerivedMatrix;

    bool _needPositionUpdate = true;
    bool _needOrientationUpdate = true;
    bool _needScaleUpdate = true;
    bool _needMatrixUpdate = true;
    bool _needDerivedMatrixUpdate = true;

public:
    this(string name, Node parent = null) @safe nothrow {
        this._name = name;
        setParent(parent);
        this.scale = Vector3(1, 1, 1);
    }
    
    /// Returns this Nodes name.
    @property string name() const @safe nothrow {
        return this._name;
    }

    /// Position relative to parent.
    @property Vector3 position() const @safe nothrow {
        return this._localPosition;
    }

    /// ditto
    @property Vector3 position(in Vector3 position) @safe nothrow {
        this._requestUpdate(Update.Position);
        this._localPosition = position;
        return this._localPosition;
    }

    /// Orientation relative to parent.
    @property Quaternion orientation() const @safe nothrow {
        return this._localOrientation;
    }

    /// ditto
    @property Quaternion orientation(Quaternion orientation) @safe nothrow {
        // Note: normalisation is not _required_ here
        orientation.normalize();
        this._requestUpdate(Update.Orientation);
        this._localOrientation = orientation;
        return this._localOrientation;
    }

    /// Scale relative to parent.
    @property Vector3 scale() const @safe nothrow {
        return this._localScale;
    }

    /// ditto
    @property Vector3 scale(in Vector3 scale) @safe nothrow {
        this._requestUpdate(Update.Scale);
        this._localScale = scale;
        return this._localScale;
    }

    /// Position relative to world.
    @property Vector3 derivedPosition() @safe nothrow {
        if(this._needPositionUpdate && this._parent) {
            // Change position vector based on parent's orientation & scale
            this._cachedDerivedPosition = this._parent.derivedOrientation * Vector3(
                this._parent.derivedScale.x * this.position.x,
                this._parent.derivedScale.y * this.position.y,
                this._parent.derivedScale.z * this.position.z);
            // Add altered position vector to parents
            this._cachedDerivedPosition += this._parent.derivedPosition;
        }
        else if(this._needPositionUpdate && this._parent is null)
            this._cachedDerivedPosition = this.position;
        this._needPositionUpdate = false;
        return this._cachedDerivedPosition;
    }

    /// Orientation relative to world.
    @property Quaternion derivedOrientation() @safe nothrow {
        if(this._needOrientationUpdate && this._parent !is null)
            this._cachedDerivedOrientation = this.orientation * this._parent.derivedOrientation;
        else if(this._needOrientationUpdate && this._parent is null)
            this._cachedDerivedOrientation = this.orientation;
        this._needOrientationUpdate = false;
        return this._cachedDerivedOrientation;
    }

    /// Scale relative to world.
    @property Vector3 derivedScale() @safe nothrow {
        if(this._needScaleUpdate && this._parent !is null) {
            this._cachedDerivedScale = Vector3(
                this.scale.x * this._parent.derivedScale.x,
                this.scale.y * this._parent.derivedScale.y,
                this.scale.z * this._parent.derivedScale.z);
        } else if(this._needScaleUpdate && this._parent is null) {
            this._cachedDerivedScale = this.scale;
        }
        this._needScaleUpdate = false;
        return this._cachedDerivedScale;
    }

    /// Local transformation Matrix.
    @property Matrix4 matrix() @safe nothrow {
        if(this._needMatrixUpdate) {
            this._cachedMatrix = this.orientation.to_matrix!(4, 4).translate(this.position.x, this.position.y, this.position.z).scale(this.scale.x, this.scale.y, this.scale.z);
            this._needMatrixUpdate = false;
        }
        return this._cachedMatrix;
    }

    /// Global transformation Matrix.
    @property Matrix4 derivedMatrix() @safe nothrow {
        if(this._needDerivedMatrixUpdate) {
            if(this._parent !is null) {
                this._cachedDerivedMatrix = this._parent.derivedMatrix * this._cachedMatrix;
            } else {
                this._cachedDerivedMatrix = this._cachedMatrix;
            }
            this._needDerivedMatrixUpdate = false;
        }
        return this._cachedDerivedMatrix;
    }

    /// Translates this Node by a Vector.
    void translate(in Vector3 vector, TransformSpace ts = TransformSpace.Local) @safe nothrow {
        if(ts == TransformSpace.Local) {
            this.position += this.orientation * vector;
        } else if(ts == TransformSpace.Parent) {
            this.position += vector;
        } else if(ts == TransformSpace.World) {
            if (this._parent !is null) {
                Vector3 v = this._parent.derivedOrientation.inverse * vector;
                this.position += Vector3(
                    v.x / this._parent.derivedScale.x,
                    v.y / this._parent.derivedScale.y,
                    v.z / this._parent.derivedScale.z);
            } else {
                this.position += vector;
            }
        }
        this._requestUpdate(Update.Position);
    }

    /// Rotates this Node by the Angle around the given axis.
    void rotate(Angle angle, Vector3 axis, TransformSpace ts) @safe nothrow {
        this.rotate(Quaternion.axis_rotation(angle.radians, axis), ts);
    }

    /// Rotates this Node by Quaternion
    void rotate(Quaternion rotation, TransformSpace ts) @safe nothrow {
        rotation.normalize();

        if(ts == TransformSpace.Local) {
            this.orientation = this.orientation * rotation;
        } else if(ts == TransformSpace.Parent) {
            this.orientation = rotation * this.orientation;
        } else if(ts == TransformSpace.World) {
            this.orientation = this.orientation * this.derivedOrientation.inverse * rotation * this.derivedOrientation;
        }
        this._requestUpdate(Update.Orientation);
    }
    
    ///
    @property void direction(Vector3 vector) @safe nothrow {
        if(vector == Vector3(0,0,0))
            return;

        Vector3 zAdjustVec = -vector;
        zAdjustVec.normalize();

        Quaternion targetWorldOrientation;
        Quaternion rotQuat;
        if ( (zAxis(this.orientation)+zAdjustVec).length_squared <  0.00005f) 
        {
            // Oops, a 180 degree turn (infinite possible rotation axes)
            // Default to yaw i.e. use current UP
            fromAngleAxis(rotQuat, degrees(180), yAxis(this.orientation));
        }
        else
        {
            // Derive shortest arc to new direction
            rotQuat = rotationTo(zAxis(this.orientation), zAdjustVec);
        }
        this.orientation = rotQuat * this.orientation;
        this._requestUpdate(Update.Orientation);
    }

    ///
    void lookAt(Vector3 point) @safe nothrow {
        this.direction = (point - this.position);
    }	

public:
    /// Creates a new Node with this Node as parent.
    Node createChildNode(string name) @safe nothrow {
        return new Node(name, this);
    }

    /// Attaches this Node to a parent Node.
    /// TODO: @safe, remove trycatch from chountuntil
    void setParent(Node parent) @trusted nothrow {
        if(this._parent !is null) {
            try {
                remove(this._parent._children, countUntil(this._parent._children, this));
            }catch(Exception e){}
        }
        if(parent !is null) {
            parent._children ~= this;
        }
        this._parent = parent;
    }

    /// Returns a path for user-friendly representation of the position
    /// of this Node in the scene graph (separated by '/' slashes).
    @property string path() const @safe nothrow {
        if(this._parent) return this._parent.path ~ "/" ~ this._name;
        else return this._name;
    }

    /// Returns whether this Node is a root Node (has no parent).
    @property bool isRoot() const @safe nothrow {
        return (this._parent is null);
    }

    /// Returns the root node of this Node (the first Node in the scene
    /// graph).
    @property Node rootNode() @safe nothrow {
        Node n = this;
        while(!n.isRoot)
            n = n._parent;
        return n;
    }
    
    /// Returns true if node is a child of this Node.
    /// TODO: @safe, remove try catch block from countuntil
    bool hasChildNode(Node node) const @trusted nothrow {
        try{
            return countUntil(this._children, node) != -1;
        }catch(Exception e){
            return false;
        }
    }
    
    /// Returns true if node is a sibling of this Node
    bool hasSiblingNode(Node node) const @safe nothrow {
        foreach(e; this._children)
            if(e is node || e.hasSiblingNode(node))
                return true;
        return false;
    }
    
    /// Returns count of children this Node has.
    ulong countChildren() const @safe nothrow {
        return this._children.length;
    }
    
    /// Returns array of children this Node has.
    @property const(Node[]) children() const @safe nothrow {
        return this._children;
    }
    
    /// Returns the Node identified by name if it is a 
    /// sibling of this Node.
    /// If it is not found it returns null.
    Node findSibling(string name) @safe nothrow {
        foreach(e; this._children)
            if(e._name == name) {
                return e;
            }
            else {
                Node n = e.findSibling(name);
                if(e !is null)
                    return e;
            }
        return null;
    }
    
public:
    /// Attach a Component to this Node.
    void attachComponent(Component c) @safe nothrow {
        c._node = this;
    }
    
    /// Detach a Component from this Node
    /// TODO: @safe, remove try catch block from countUntil
    void detachComponent(Component c) @trusted nothrow {
        c._node = null;
        try {
            remove(this._components, countUntil(this._components, c));
        }catch(Exception e){}
    }
    
    // Returns all components attached to this node
    @property const(Component[]) components() const @safe nothrow {
        return this._components;
    }        

private:
    enum Update {
        Position,
        Scale,
        Orientation
    }

    /// Informs the Node and all child nodes to update parts of their
    /// cached transformation state.
    void _requestUpdate(Update update) @safe nothrow {
        if(update == Update.Position)
            this._needPositionUpdate = true;
        if(update == Update.Scale)
            this._needScaleUpdate = true;
        if(update == Update.Orientation)
            this._needOrientationUpdate = true;

        this._needMatrixUpdate = true;
        this._needDerivedMatrixUpdate = true;

        foreach(c; this._children)
            c._requestUpdate(update);
        
        foreach(c; this._components)
            c._needUpdate = true;
    }
}

/**
 * A component modifies a node and attaches more functions or objects to
 * it.
 */
class Component {
private:    
    Node _node; //TODO: FIXME: this has to become a weak_reference!
    string _name;
    bool _needUpdate = false;

public:
    this(string name) @safe nothrow {
        this._name = name;
    }

    /// Returns a path for user-friendly representation of the position
    /// of this Component in the scene graph (separated by '/' slashes).
    @property string path() const @safe nothrow {
        if(this._node) return this._node.path ~ "/" ~ this._name;
        else return "<unattached>/" ~ this._name;
    }
    
    /// Returns the Node this Component is attached to.
    @property Node node() @safe nothrow {
        return this._node;
    }
    
    /// Returns this Components name.
    @property string name() const @safe nothrow {
        return this._name;
    }
}

/**
 * CameraComponent
 */
class CameraComponent : Component{
private:	
    Matrix4 _projectionMatrix;
    Matrix4 _cachedViewMatrix;
public:
    ///
    this(string name, Angle fovY, float aspectRatio, float front, float back) @safe nothrow {
        float tangent = tan((fovY/2).radians);   // tangent of half fovY
        float height = front * tangent;          // half height of near plane
        float width = height * aspectRatio;      // half width of near plane
        // params: left, right, bottom, top, near, far
        this(name, -width, width, -height, height, front, back);
    }	

    ///
    this(string name, float left, float right, float top, float bottom, float near, float far) @safe nothrow {		
        super(name);
        float A = 2 * near / (right - left);
        float B = 2 * near / (top - bottom);
        float C = (right + left) / (right - left);
        float D = (top + bottom) / (top - bottom);
        float q = - (far + near) / (far - near);
        float qn = - 2 * (far * near) / (far - near);
        this._projectionMatrix = Matrix4(Vector4(A,0,0,0),Vector4(0,B,0,0),Vector4(C,D,q,-1),Vector4(0,0,qn,0));
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
            makeTransform(this._cachedViewMatrix, this._node.position, Vector3(1,1,1), this._node.orientation);
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
}
