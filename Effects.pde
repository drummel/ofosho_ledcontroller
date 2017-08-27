import java.awt.Color;

HashMap<String, Effect> effects;
void initEffects(PApplet window)
{
  Class<?>[] effect_classes = {
    MouseDot.class,
    Rainbow.class,
  };
  effects = new HashMap<String, Effect>();
  
  /*
  for(Class<?> clazz : effect_classes) {
    println(clazz.getName());
    Constructor<Effect> cons = (Constructor<Effect>)clazz.getConstructors()[0]; //(new Class[]{ PApplet.class });
    Effect effect = (Effect)cons.newInstance(window);
    effects.put(clazz.getName(), effect);
  }
  System.exit(1);
  */
  
  effects.put("MouseDot", new MouseDot(window));
  effects.put("Rainbow", new Rainbow(window));
}

public abstract class Effect {
  PApplet window;
  int frame_num;
  Effect(PApplet window)
  {
    this.window = window;
    this.frame_num = 0; 
  }
  
  void render(int frame_num)
  {
  }
  
  void setPixel(int x, int y, color col) {
    window.pixels[y * CANVAS_WIDTH + x] = col;
  }
}


public class Rainbow extends Effect {
  PImage dot;
    
  Rainbow(PApplet window)
  {
    super(window);
  }
  
  void render(int frame_num) {
    window.loadPixels();
    for(int x = 0; x < CANVAS_WIDTH; x++) {
      color col = Color.HSBtoRGB(((frame_num + x) & 0xFF) / 255.0, 1.0, 1.0);
      for(int y = 0; y < CANVAS_HEIGHT; y++) {
        setPixel(x, y, col);
      }
    }
    window.updatePixels();
  }
}


public class MouseDot extends Effect {
  PImage dot;
  
  MouseDot(PApplet window) {
    super(window);
    // Load a sample image
    dot = loadImage("dot.png");
  }
  
  void render(int frame_num) {
    // Draw the image, centered at the mouse location
    float dotSize = CANVAS_HEIGHT * 0.7;
    window.image(dot, window.mouseX - dotSize/2, window.mouseY - dotSize/2, dotSize, dotSize);
  }
}