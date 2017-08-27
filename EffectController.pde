import java.lang.reflect.*;

public class EffectController {
  PApplet main_window;
  PlasticMask plastic_mask;
  Shapes shapes;
  OPC opc;
  Simulation simulation = null;
  String current_effect = null;
  int frame_num = 0;
  
  EffectController(PApplet main_window)
  {
    this.main_window = main_window;
    
    // Connect to the local instance of fcserver
    opc = new OPC(this.main_window, FADECANDY_HOST, FADECANDY_PORT);
    shapes = (new InitShapes()).initializeShapes(opc);
    plastic_mask = new PlasticMask(shapes);
    
    initEffects(this.main_window);
    current_effect = "Rainbow";
    
    if (SIMULATION_ENABLED) {
      simulation = new Simulation(shapes, plastic_mask);
      simulation.start();
    }
  }
  
  public void renderEffects()
  {
    frame_num++;
    main_window.background(0);
    Effect effect = effects.get(current_effect);
    
    effect.render(frame_num);
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