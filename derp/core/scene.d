module derp.core.scene;

import std.algorithm;

import derp.core.geo;

enum TransformSpace {
    Local,
    Parent,
    World
}

class Node {
    Node[] children;
    Component[] components;
    Node parent = null;
    string name;

protected:
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
    this(string name, Node parent = null) {
        this.name = name;
        setParent(parent);
        this.scale = Vector3(1, 1, 1);
    }

    /// Position relative to parent.
    @property Vector3 position(){
        return this._localPosition;
    }

    /// ditto
    @property Vector3 position(in Vector3 position) {
        this.requestUpdate(Update.Position);
        this._localPosition = position;
        return this._localPosition;
    }

    /// Orientation relative to parent.
    @property Quaternion orientation() {
        return this._localOrientation;
    }

    /// ditto
    @property Quaternion orientation(Quaternion orientation) {
        // Note: normalisation is not _required_ here
        orientation.normalize();
        this.requestUpdate(Update.Orientation);
        this._localOrientation = orientation;
        return this._localOrientation;
    }

    /// Scale relative to parent.
    @property Vector3 scale() {
        return this._localScale;
    }

    /// ditto
    @property Vector3 scale(in Vector3 scale) {
        this.requestUpdate(Update.Scale);
        this._localScale = scale;
        return this._localScale;
    }

    /// Position relative to world.
    @property Vector3 derivedPosition() {
        if(this._needPositionUpdate && this.parent) {
            // Change position vector based on parent's orientation & scale
            this._cachedDerivedPosition = this.parent.derivedOrientation * Vector3(
                this.parent.derivedScale.x * this.position.x,
                this.parent.derivedScale.y * this.position.y,
                this.parent.derivedScale.z * this.position.z);
            // Add altered position vector to parents
            this._cachedDerivedPosition += this.parent.derivedPosition;
        }
        else if(this._needPositionUpdate && this.parent is null)
            this._cachedDerivedPosition = this.position;
        this._needPositionUpdate = false;
        return this._cachedDerivedPosition;
    }

    /// Orientation relative to world.
    @property Quaternion derivedOrientation() {
        if(this._needOrientationUpdate && this.parent !is null)
            this._cachedDerivedOrientation = this.orientation * this.parent.derivedOrientation;
        else if(this._needOrientationUpdate && this.parent is null)
            this._cachedDerivedOrientation = this.orientation;
        this._needOrientationUpdate = false;
        return this._cachedDerivedOrientation;
    }

    /// Scale relative to world.
    @property Vector3 derivedScale() {
        if(this._needScaleUpdate && this.parent !is null) {
            this._cachedDerivedScale = Vector3(
                this.scale.x * this.parent.derivedScale.x,
                this.scale.y * this.parent.derivedScale.y,
                this.scale.z * this.parent.derivedScale.z);
        } else if(this._needScaleUpdate && this.parent is null) {
            this._cachedDerivedScale = this.scale;
        }
        this._needScaleUpdate = false;
        return this._cachedDerivedScale;
    }

    /// Local transformation matrix.
    @property Matrix4 matrix() {
        if(this._needMatrixUpdate) {
            this._cachedMatrix = this.orientation.to_matrix!(4, 4).translate(this.position.x, this.position.y, this.position.z).scale(this.scale.x, this.scale.y, this.scale.z);
            this._needMatrixUpdate = false;
        }
        return this._cachedMatrix;
    }

    /// Global transformation matrix.
    @property Matrix4 derivedMatrix() {
        if(this._needDerivedMatrixUpdate) {
            if(this.parent) {
                this._cachedDerivedMatrix = this.parent.derivedMatrix * this._cachedMatrix;
            } else {
                this._cachedDerivedMatrix = this._cachedMatrix;
            }
            this._needDerivedMatrixUpdate = false;
        }
        return this._cachedDerivedMatrix;
    }

    /// Translates this node by a vector.
    void translate(in Vector3 vector, TransformSpace ts = TransformSpace.Local) {
        if(ts == TransformSpace.Local) {
            this.position += this.orientation * vector;
        } else if(ts == TransformSpace.Parent) {
            this.position += vector;
        } else if(ts == TransformSpace.World) {
            if (this.parent) {
                Vector3 v = this.parent.derivedOrientation.inverse * vector;
                this.position += Vector3(
                    v.x / this.parent.derivedScale.x,
                    v.y / this.parent.derivedScale.y,
                    v.z / this.parent.derivedScale.z);
            } else {
                this.position += vector;
            }
        }
        this.requestUpdate(Update.Position);
    }

    /// Rotates this node by the angle around the given axis.
    void rotate(Angle angle, Vector3 axis, TransformSpace ts) {
        this.rotate(Quaternion.axis_rotation(angle.radians, axis), ts);
    }

    /// Rotates this node by
    void rotate(Quaternion rotation, TransformSpace ts) {
        rotation.normalize();

        if(ts == TransformSpace.Local) {
            this.orientation = this.orientation * rotation;
        } else if(ts == TransformSpace.Parent) {
            this.orientation = rotation * this.orientation;
        } else if(ts == TransformSpace.World) {
            this.orientation = this.orientation * this.derivedOrientation.inverse * rotation * this.derivedOrientation;
        }
        this.requestUpdate(Update.Orientation);
    }

    /// Creates a new Node with this Node as parent.
    Node createChildNode(string name) {
        return new Node(name, this);
    }

    /// Attaches this Node to a parent Node.
    void setParent(Node parent) {
        if(this.parent) {
            remove(this.parent.children, indexOf(this.parent.children, this));
        }
        if(parent) {
            parent.children ~= this;
        }
        this.parent = parent;
    }

    /// Returns a path for user-friendly representation of the position
    /// of this node in the scene graph (separated by '/' slashes).
    @property string path() {
        if(parent) return parent.path ~ "/" ~ name;
        else return name;
    }

    /// Returns whether this Node is a root node (has no parent).
    @property bool isRoot() {
        return (this.parent is null);
    }

    /// Returns the root node of this node (the first node in the scene
    /// graph).
    @property Node rootNode() {
        Node n = this;
        while(n.parent) n = n.parent;
        return n;
    }

    /// Adds a Component to this Node.
    void addComponent(Component c) {
        c.setNode(this);
    }

private:
    enum Update {
        Position,
        Scale,
        Orientation
    }

    /// Informs the Node and all child nodes to update parts of their
    /// cached transformation state.
    void requestUpdate(Update update) {
        if(update == Update.Position)
            this._needPositionUpdate = true;
        if(update == Update.Scale)
            this._needScaleUpdate = true;
        if(update == Update.Orientation)
            this._needOrientationUpdate = true;

        this._needMatrixUpdate = true;
        this._needDerivedMatrixUpdate = true;

        foreach(c; this.children)
            c.requestUpdate(update);
    }
}

/**
 * A component modifies a node and attaches more functions or objects to
 * it.
 */
class Component {
    Node node;
    string name;

    this(string name) {
        this.name = name;
    }

    @property string path() {
        if(node) return node.path ~ "/" ~ name;
        else return "<unattached>/" ~ name;
    }

    void setNode(Node node) {
        if(this.node) {
            remove(this.node.components, indexOf(this.node.components, this));
        }
        if(node) {
            node.components ~= this;
        }
        this.node = node;
    }
}
