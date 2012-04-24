import derp.all;
import std.stdio;

void main() {
    ResourceSettings s = new ResourceSettings("a", 1, "b", 10);
    assert(s.a == "1");
    assert(s.b == "10");
    s.a = 2;
    assert(s.a == "2");
    s.d = 42;
    assert(s.d == "42");
    assert(s.get!int("a") + s.get!int("d") == 44);

    ResourceManager manager = new ResourceManager();
}
