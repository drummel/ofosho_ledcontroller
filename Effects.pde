import java.awt.Color;

List<IEffect> initEffects(EffectUtils utils)
{
  List<IEffect> effects = new ArrayList<IEffect>();
  effects.add(new Plasma(utils));
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


public class Plasma extends CanvasEffect {
  double[][] plasma1, plasma2;
  Plasma(EffectUtils utils)
  {
    super(utils);

    plasma1 = new double[CANVAS_HEIGHT * 2][CANVAS_WIDTH * 2];
    plasma2 = new double[CANVAS_HEIGHT * 2][CANVAS_WIDTH * 2];
    for(int y = 0; y < CANVAS_HEIGHT * 2; y++) {
      int delta_y = CANVAS_HEIGHT - y;
      for(int x = 0; x < CANVAS_WIDTH * 2; x++) {
        int delta_x = CANVAS_WIDTH - x;
        plasma1[y][x] = 128.0 + 127.0 * Math.cos( Math.hypot(delta_x, delta_y) / 64.0);
        plasma2[y][x] = 90.0 * Math.sin( Math.hypot(12.0, delta_x, delta_y) ) / 32.0;
      }
    }
  }
  
  void render() {
    utils.loadPixels();
    float time = (float)utils.frame_num;
    int sx1 = (CANVAS_WIDTH + (int)( (CANVAS_WIDTH - 2) * Math.sin(time / 137.0))) / 2;
    int sx2 = (CANVAS_WIDTH + (int)( (CANVAS_WIDTH - 2) * Math.sin(-time / 125.0))) / 2;
    int sx3 = (CANVAS_WIDTH + (int)( (CANVAS_WIDTH - 2) * Math.sin(-time / 123.0))) / 2;
    int y1 = (CANVAS_HEIGHT + (int)( (CANVAS_HEIGHT - 2) * Math.cos(time / 123.0))) / 2;
    int y2 = (CANVAS_HEIGHT + (int)( (CANVAS_HEIGHT - 2) * Math.cos(-time / 85.0))) / 2;
    int y3 = (CANVAS_HEIGHT + (int)( (CANVAS_HEIGHT - 2) * Math.cos(-time / 108.0))) / 2;    
    
    for(int y = 0 ; y < CANVAS_HEIGHT; y++) {
      int x1 = sx1, x2 = sx2, x3 = sx3;
      for(int x = 0 ; x < CANVAS_WIDTH; x++) {
        int a = (int)(plasma2[y1][x1] + plasma1[y2][x2] + plasma2[y3][x3]);
        utils.setPixel(x, y,
          color(
            (a << 1) & 0xFF,
            (a << 2) & 0xFF,
            (a << 3) & 0xFF
          )
         );
         x1++;
         x2++;
         x3++;
      }
      y1++; y2++; y3++;
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