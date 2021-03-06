/**
    Bugs: _parent Node has to become a weak referece,
    else the GC might not free it. (double linked)
*/
module derp.core.scene;

import std.algorithm;

import derp.math.all;
import derp.core.geo;
import derp.graphics.render;

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
    Vector3 _localPosition = Vector3(0, 0, 0);
    Quaternion _localOrientation = Quaternion.identity;
    Vector3 _localScale = Vector3(1, 1, 1);

    Vector3 _cachedDerivedPosition;
    Quaternion _cachedDerivedOrientation;
    Vector3 _cachedDerivedScale;

    Matrix4 _cachedMatrix;
    Matrix4 _cachedDerivedMatrix;
    Node _cachedRootNode = null; //TODO: FIXME: this has to become a weak_reference!

    bool _needPositionUpdate = true;
    bool _needOrientationUpdate = true;
    bool _needScaleUpdate = true;
    bool _needMatrixUpdate = true;
    bool _needDerivedMatrixUpdate = true;
    bool _needRootNodeUpdate = true;


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

    /// Rotation on x-y plane / around z-axis (for 2D elements)
    @property Angle rotation() const @safe nothrow {
        return radians(this._localOrientation.roll());
    }

    /// ditto
    @property void rotation(Angle angle) @safe nothrow {
        this._localOrientation = Quaternion.zrotation(angle.radians);
        this._requestUpdate(Update.Orientation);
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

    /// ditto
    @property Vector3 scale(in float s) @safe nothrow {
        this._requestUpdate(Update.Scale);
        this._localScale = Vector3(s, s, s);
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
            //this._cachedMatrix = this.orientation.to_matrix!(4, 4).translate(this.position.x, this.position.y, this.position.z).scale(this.scale.x, this.scale.y, this.scale.z);
            makeTransform(this._cachedMatrix, this.position, this.scale, this.orientation);
            this._needMatrixUpdate = false;
        }
        return this._cachedMatrix;
    }

    /// Global transformation Matrix.
    @property Matrix4 derivedMatrix() @safe nothrow {
        if(this._needDerivedMatrixUpdate) {
            if(this.isRoot) {
                this._cachedDerivedMatrix = this.matrix;
            } else {
                this._cachedDerivedMatrix = this._parent.derivedMatrix * this.matrix;
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

        Vector3 xAxis;
        Vector3 yAxis;
        Vector3 zAxis;
        //TODO: UFCS
        this.orientation.toAxis(xAxis, yAxis, zAxis);

        if (xAxis.length_squared <  0.00005f) {
            // Oops, a 180 degree turn (infinite possible rotation axes)
            // Default to yaw i.e. use current UP
            fromAngleAxis(rotQuat, degrees(180), yAxis);
        } else {
            // Derive shortest arc to new direction
            rotQuat = rotationTo(zAxis, zAdjustVec);
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
        _requestUpdate(Update.RootNode);
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
        if(this._needRootNodeUpdate)
        {
            this._cachedRootNode = this;
            while(!this._cachedRootNode.isRoot)
                this._cachedRootNode = this._cachedRootNode._parent;
        }
        return this._cachedRootNode;
    }

    /// Returns true if node is a child of this Node.
    /// TODO: @safe, remove try catch block from countuntil
    bool hasChildNode(Node node) const @trusted nothrow {
        try{
            return countUntil(this._children, node) != -1;
        } catch(Exception e) {
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
        if(c._node !is null && c._node !is this) {
            c._node.detachComponent(c);
        }
        c._node = this;
        if(this.hasComponent(c))
            return;
        this._components ~= c;
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

    /// Checks whether the component is attached to this node
    /// TODO: @safe, remove try catch block from canFind
    bool hasComponent(Component c) const @trusted nothrow {
        try {
            return canFind(this._components, c);
        } catch(Exception e) {}
        return false;
    }

private:
    enum Update {
        Position,
        Scale,
        Orientation,
        RootNode
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
        if(update == Update.RootNode)
            this._needRootNodeUpdate = true;

        this._needMatrixUpdate = true;
        this._needDerivedMatrixUpdate = true;

        foreach(c; this._children)
            c._requestUpdate(update);

        foreach(c; this._components)
            c._needUpdate = true;
    }
public:
    void prepareRender(RenderQueue queue) const {
        foreach(c; this.components) {
            c.prepareRender(queue);
        }
        foreach(c; this.children) {
            c.prepareRender(queue);
        }
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
protected:
    bool _needUpdate = true;

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

    void prepareRender(RenderQueue queue) const {
        // do nothing, since most components won't
        // be visible anyway
    }
}
