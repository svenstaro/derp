module derp.graphics.light;

import derp.core.scene;
import derp.graphics.draw;
import derp.graphics.render;

class LightComponent : Component, Renderable {
public:
    Color color;
    float energy;

    this(string name, Color color = Color.White, float energy = 1.0) {
        super(name);
        this.color = color;
        this.energy = energy;
    }

    void prepareRender(RenderQueue queue) {
        queue.push(cast(Renderable)this);
    }

    void render(RenderQueue queue) {
    }
}
