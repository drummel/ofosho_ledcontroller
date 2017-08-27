public class EffectController {
  PApplet main_window;
  PlasticMask plastic_mask;
  Shapes shapes;
  OPC opc;
  PImage dot;
  Simulation simulation = null;
    
  EffectController(PApplet main_window)
  {
    this.main_window = main_window;
    
    // Connect to the local instance of fcserver
    opc = new OPC(this.main_window, FADECANDY_HOST, FADECANDY_PORT);
    shapes = (new InitShapes()).initializeShapes(opc);
    plastic_mask = new PlasticMask(shapes);
  
    // Load a sample image
    dot = loadImage("dot.png");
  
    if (SIMULATION_ENABLED) {
      simulation = new Simulation(shapes, plastic_mask);
      simulation.start();
    }
  }
  
  public void renderEffects()
  {
    main_window.background(0);
    
    // Draw the image, centered at the mouse location
    float dotSize = CANVAS_HEIGHT * 0.7;
    main_window.image(dot, mouseX - dotSize/2, mouseY - dotSize/2, dotSize, dotSize);
    
    main_window.loadPixels();
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