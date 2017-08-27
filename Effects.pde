import java.awt.Color;

List<IEffect> initEffects(EffectUtils utils)
{
  List<IEffect> effects = new ArrayList<IEffect>();
  effects.add(new Rainbow(utils));
  effects.add(new RotatingRainbow(utils));
  effects.add(new MouseDot(utils));
  return effects;
}

interface IEffect {
  void render();
  void postRender();
}




/**
 * A Canvas effect is where the effect draws all over the canvas, and then the LED color values are sampled
 * from certain points on the canvas. (Contrast with PointEffect where each LED's color is explicitly calculated).
 */
public abstract class CanvasEffect implements IEffect {
  EffectUtils utils;
  CanvasEffect(EffectUtils utils)
  {
    this.utils = utils; 
  }
  
  void postRender() {
    // Update each LEDs record of which color it is currently displaying.
    for(LedPixel led_pixel: utils.leds) {
      led_pixel.col = utils.window.pixels[(int)led_pixel.canvas_position.y * CANVAS_WIDTH + (int)led_pixel.canvas_position.x];
    } 
  }
}

/**
 * A PointEffect's render() loop just calculates and sets each LED's color explicitly.
 */
public abstract class PointEffect implements IEffect {
  EffectUtils utils;
  PointEffect(EffectUtils utils)
  {
    this.utils = utils; 
  }
  
  void postRender() {}
}



public class Rainbow extends CanvasEffect {
  Rainbow(EffectUtils utils)
  {
    super(utils);
  }
  
  void render() {
    utils.loadPixels();
    for(int x = 0; x < CANVAS_WIDTH; x++) {
      color col = Color.HSBtoRGB(((utils.frame_num + x) & 0xFF) / 255.0, 1.0, 1.0);
      for(int y = 0; y < CANVAS_HEIGHT; y++) {
        utils.setPixel(x, y, col);
      }
    }
    utils.updatePixels();
  }
}

public class RotatingRainbow extends PointEffect {
  RotatingRainbow(EffectUtils utils)
  {
    super(utils);
  }
  
  void render() {
    float angle = (float)Math.PI * 2.0 * (utils.frame_num / 500.0);
    SimpleMatrix xform =
        LinearXforms.rotate(angle)
        .mult(LinearXforms.translate(-CANVAS_WIDTH / 2.0, -CANVAS_HEIGHT / 2.0)
        );
        
    for(LedPixel led_pixel : utils.leds) {
      PVector new_pos = LinearXforms.multMatrixByPVector(xform, led_pixel.canvas_position);
      led_pixel.col = Color.HSBtoRGB(((int)(utils.frame_num + new_pos.x) & 0xFF) / 255.0, 1.0, 1.0);
    }
  }
}


public class MouseDot extends CanvasEffect {
  PImage dot;
  
  MouseDot(EffectUtils utils) {
    super(utils);
    // Load a sample image
    dot = loadImage("dot.png");
  }
  
  void render() {
    utils.clearScreen();
    // Draw the image, centered at the mouse location
    float dotSize = CANVAS_HEIGHT * 0.7;
    utils.window.image(
      dot,
      utils.window.mouseX - dotSize/2,
      utils.window.mouseY - dotSize/2, dotSize,
      dotSize
    );
    utils.loadPixels();
  }
}