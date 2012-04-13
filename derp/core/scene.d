module derp.core.scene;

import std.algorithm;

class Node {
    Node[] children;
    Component[] components;
    Node parent = null;
    string name;

    this(string name, Node parent = null) {
        this.name = name;
        setParent(parent);
    }

    Node createChildNode(string name) {
        return new Node(name, this);
    }

    void setParent(Node parent) {
        if(this.parent) {
            remove(this.parent.children, indexOf(this.parent.children, this));
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
        return !(cast(bool)this.parent);
    }

    @property Node rootNode() {
        Node n = this;
        while(n.parent) n = n.parent;
        return n;
    }

    void addComponent(Component c) {
        c.setNode(this);
    }
}

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
