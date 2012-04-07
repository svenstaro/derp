module derp.core.scene;

import std.algorithm;

class Node {
    Node[] children;
    Node parent = null;
    string name;

    Component[] components;

    this(string name, Node parent = null) {
        this.name = name;
        setParent(parent);
    }

    Node createChildNode(string name) {
        return new Node(name, this);
    }

    void setParent(Node parent) {
        if(this.parent) {
            // This node is already the child of another node,
            // remove it from its children list.
            remove(this.parent.children, indexOf(this.parent.children, this));
            // this.parent.children.remove(this);
        }

        if(parent) {
            parent.children ~= this;
        }

        this.parent = parent;
    }

    @property string path() {
        if(parent) return parent.path ~ "/" ~ name;
        else return name;
    }

    @property bool isRoot() {
        return cast(bool)this.parent;
    }

    @property Node rootNode() {
        Node n = this;
        while(n.parent) n = n.parent;
        return n;
    }
}

class Component {

}
