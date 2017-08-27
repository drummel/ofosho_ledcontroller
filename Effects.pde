import java.awt.Color;

List<Effect> initEffects(EffectUtils utils)
{
  List<Effect> effects = new ArrayList<Effect>();
  effects.add(new Rainbow(utils));
  effects.add(new MouseDot(utils));
  return effects;
}

interface IEffect {
  void render();
}

public abstract class Effect implements IEffect {
  EffectUtils utils;
  Effect(EffectUtils utils)
  {
    this.utils = utils; 
  }
}


public class Rainbow extends Effect {
  PImage dot;
    
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


public class MouseDot extends Effect {
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