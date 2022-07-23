import java.lang.reflect.*;

public class EffectController {
  PApplet main_window;
  CanvasPainter painter;
  PlasticMask plastic_mask;
  Shapes shapes;
  Simulation simulation = null;
  final int FRAME_RATE = 60;
  final int EFFECT_DURATION_S = 30;   // Seconds between cycling effects
  int frame_num = 0;
  int effect_duration_cnt = 0;
  List<IEffect> effects;
  Iterator<IEffect> effect_iterator;
  IEffect current_effect = null;
  
  EffectController(PApplet main_window, Shapes shapes, List<IEffect> effects, PlasticMask plastic_mask)
  {
    this.main_window = main_window;
    this.painter = painter;
    this.shapes = shapes;
    this.effects = effects;
    this.plastic_mask = plastic_mask;
    
    this.painter = new CanvasPainter(this.main_window);

    effect_iterator = effects.iterator();
    cycleToNextEffect();
  }
  
  public void cycleToNextEffect()
  {
    effect_duration_cnt = EFFECT_DURATION_S * FRAME_RATE;
    if (!effect_iterator.hasNext()) {
      effect_iterator = effects.iterator();
    }
    main_window.background(0);
    current_effect = effect_iterator.next();
    current_effect.reset(shapes);
    println("Running effect: " + current_effect.getClass().getSimpleName());
  }
  
  public void renderEffects()
  {
    if(effect_duration_cnt-- <= 0) {
      cycleToNextEffect();
    }

    painter.loadPixels();
    current_effect.render(painter, shapes, frame_num++);
    painter.updatePixels();
    // Update each LEDs record of which color it is currently displaying.
    for(LedPixel led_pixel: shapes.all_leds) {
       led_pixel.col = painter.getPixel((int)led_pixel.canvas_position.x, (int)led_pixel.canvas_position.y);
    }
    showPlasticMask();
  }

  // Faintly overlay the plastic outline on the main window.
  protected void showPlasticMask() {
    main_window.blend(plastic_mask.mask,
      0, 0, main_window.width, main_window.height,
      0, 0, main_window.width, main_window.height,
      ADD
    );
  }
}


/* Convenience class, used by an Effect to easily read/write pixels on the canvas */
public class CanvasPainter {

  PApplet window;
  int canvas_width;
  int canvas_height;

  CanvasPainter(PApplet window)
  {
    this.window = window;
    this.canvas_width = window.width;
    this.canvas_height = window.height;
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

  color getPixel(int x, int y) {
    return window.pixels[y * canvas_width + x];
  }
  
  void setPixel(int x, int y, color col) {
    window.pixels[y * canvas_width + x] = col;
  }

  void setLedPixel(LedPixel led_pixel, color col) {
    led_pixel.col = col;
    this.setPixel((int)led_pixel.canvas_position.x, (int)led_pixel.canvas_position.y, col);
  }
}
