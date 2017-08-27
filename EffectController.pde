import java.lang.reflect.*;

public class EffectController {
  PApplet main_window;
  PlasticMask plastic_mask;
  Shapes shapes;
  OPC opc;
  Simulation simulation = null;
  int frame_num = 0;
  List<Effect> effects;
  Iterator<Effect> effect_iterator;
  Effect current_effect = null;
  EffectUtils effect_utils;
  
  EffectController(PApplet main_window)
  {
    this.main_window = main_window;
    
    // Connect to the local instance of fcserver
    opc = new OPC(this.main_window, FADECANDY_HOST, FADECANDY_PORT);
    shapes = (new InitShapes()).initializeShapes(opc);
    plastic_mask = new PlasticMask(shapes);
    
    effect_utils = new EffectUtils(this.main_window);
    effects = initEffects(effect_utils);
    effect_iterator = effects.iterator();
    cycleToNextEffect();
    
    if (SIMULATION_ENABLED) {
      simulation = new Simulation(shapes, plastic_mask);
      simulation.start();
    }
  }
  
  public void cycleToNextEffect()
  {
    if (!effect_iterator.hasNext()) {
      effect_iterator = effects.iterator();
    }
    current_effect = effect_iterator.next();
  }
  
  public void renderEffects()
  {
    effect_utils.incrementFrameNum();    
    current_effect.render();
    updateLedColors();
    showPlasticMask();
  }
  
  // Update each LEDs record of which color it is currently displaying.
  protected void updateLedColors()
  {
    for(Shape shape: shapes.shapes) {
      for(LedPixel led_pixel: shape.leds) {
        led_pixel.col = main_window.pixels[(int)led_pixel.canvas_position.y * CANVAS_WIDTH + (int)led_pixel.canvas_position.x];
      }
    }
  }
  
  // Faintly show the plastic outline.
  protected void showPlasticMask() {
    main_window.blend(plastic_mask.mask,
      0, 0, CANVAS_WIDTH, CANVAS_HEIGHT,
      0, 0, CANVAS_WIDTH, CANVAS_HEIGHT,
      ADD
    );
  }
}


public class EffectUtils {
  PApplet window;
  int frame_num;
  EffectUtils(PApplet window)
  {
    this.window = window;
    this.frame_num = 0; 
  }
  
  void incrementFrameNum() {
    frame_num++;
  }
  
  void clearScreen() {
    window.background(0); 
  }
  
  void loadPixels() {
    window.loadPixels();
  }
  void updatePixels() {
    window.updatePixels();
  }
  
  void setPixel(int x, int y, color col) {
    window.pixels[y * CANVAS_WIDTH + x] = col;
  }
}