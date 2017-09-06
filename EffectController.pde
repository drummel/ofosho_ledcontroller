import java.lang.reflect.*;

public class EffectController {
  PApplet main_window;
  PlasticMask plastic_mask;
  Shapes shapes;
  OPC opc;
  Simulation simulation = null;
  final int FRAME_RATE = 60;
  final int EFFECT_DURATION_S = 30;   // Seconds between cycling effects
  int frame_num = 0;
  int effect_duration_cnt = 0;
  List<IEffect> effects;
  Iterator<IEffect> effect_iterator;
  IEffect current_effect = null;
  EffectUtils effect_utils;
  
  EffectController(PApplet main_window)
  {
    this.main_window = main_window;
    
    // Connect to the local instance of fcserver
    opc = new OPC(this.main_window, FADECANDY_HOST, FADECANDY_PORT);
    shapes = (new InitShapes()).initializeShapes(opc);
    plastic_mask = new PlasticMask(shapes);
    
    effect_utils = new EffectUtils(this.main_window, shapes);
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
    effect_duration_cnt = EFFECT_DURATION_S * FRAME_RATE;
    if (!effect_iterator.hasNext()) {
      effect_iterator = effects.iterator();
    }
    main_window.background(0);
    current_effect = effect_iterator.next();
  }
  
  public void renderEffects()
  {
    effect_utils.incrementFrameNum();
    if(effect_duration_cnt-- <= 0) {
      cycleToNextEffect();
    }
    current_effect.render();
    current_effect.postRender();
    showPlasticMask();
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
  List<LedPixel> leds;
  Shapes shapes;
  
  EffectUtils(PApplet window, Shapes shapes)
  {
    this.window = window;
    this.frame_num = 0;
    this.shapes = shapes;
    
    leds = new ArrayList<LedPixel>();
    for(Shape shape : shapes.shapes) {
      for(LedPixel p: shape.leds) {
        leds.add(p);
      }
    }
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