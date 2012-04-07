/**
 * Draws simple shapes.
 */

module derp.graphics.draw;

class Color {
    float r, g, b, a;

    this(float r, float g, float b, float a = 1) {
        this.r = r;
        this.g = g;
        this.b = b;
        this.a = a;
    }
}
