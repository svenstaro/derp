import std.stdio;
import derp.all;

void main() {
    Triangle2 t = Triangle2(
            Vector2(0, 0),
            Vector2(1, 0),
            Vector2(0, 1)
            );

    assert(t.containsPoint(Vector2(0, 0)) == true);
    assert(t.containsPoint(Vector2(0, 2)) == false);
    assert(t.containsPoint(Vector2(1, 1)) == false);
    assert(t.containsPoint(Vector2(0.5, 0.5)) == true);
    assert(t.containsPoint(Vector2(0.6, 0.5)) == false);
    assert(t.containsPoint(Vector2(0.8, 0.1)) == true);
    assert(t.containsPoint(Vector2(-1, -1)) == false);
}
