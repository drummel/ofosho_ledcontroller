public class Simulation {
  Shapes shapes;
  PlasticMask plastic_mask;
  SimWindow simulation_window;
  
  final int INTENSITY_MAP_SIZE = 50; // A square grid of pixels, with the LED at the center.
  float[] intensity_map;
  PImage intensity_image;
  int canvas_width, canvas_height;
  
  Simulation(Shapes shapes, int canvas_width, int canvas_height, PlasticMask plastic_mask)
  {
    this.shapes = shapes;
    this.canvas_width = canvas_width;
    this.canvas_height = canvas_height;
    this.plastic_mask = plastic_mask;
    
    initIntensityMap();
    simulation_window = new SimWindow(this, canvas_width, canvas_height);
  }
  
  public void start()
  {
    String[] args = {"TwoFrameTest"};
    PApplet.runSketch(args, simulation_window);
  }
  
  protected void initIntensityMap() {
    PVector led_position = new PVector(INTENSITY_MAP_SIZE/2, INTENSITY_MAP_SIZE/2);
    intensity_map = new float[INTENSITY_MAP_SIZE * INTENSITY_MAP_SIZE];
    intensity_image = createImage(INTENSITY_MAP_SIZE, INTENSITY_MAP_SIZE, ARGB);
    
    // These parameters affect the falloff rate.
    //float p1 = 1.0, p2 = 1.0;
    
    for(int y = 0; y < INTENSITY_MAP_SIZE; y++) {
      for(int x = 0; x < INTENSITY_MAP_SIZE; x++) {
        // Generate an intensity (from 0 -> 1) for this pixel. The middle of the map is where the LED pixel is.
        float distance = led_position.dist(new PVector(x, y));
        float intensity = 1.0;
        if (distance >= 0.0005) {
          //intensity = 1.0 / (p1 * distance + p2 * distance * distance);
          // intensity = 1.0 / (float)(INTENSITY_MAP_SIZE / 2);
          intensity = 1.0 - distance / (float)(INTENSITY_MAP_SIZE / 2);
          intensity = Math.min(1.0, Math.max(0.0, intensity));
        }
        intensity_map[y * INTENSITY_MAP_SIZE + x] = intensity;
      }
    }
  }
  
  /**
   * Uses the LED color values to render a simulation of what it looks like in real life.
   */
  public void render(PApplet canvas) {
    canvas.background(0);
    for(Shape shape: shapes.shapes) {
      for(LedPixel led_pixel: shape.leds) {
        renderPixel(canvas, led_pixel);
      }
    }
    
    // All pixels rendered. Now let's apply the mask to blank out the areas that are not covered by plastic.
    canvas.blend(plastic_mask.inverse_mask,
      0, 0, canvas_width, canvas_height,
      0, 0, canvas_width, canvas_height,
      SUBTRACT
    );
    
    // Add a hint of where the plastic is.
    canvas.blend(plastic_mask.mask,
      0, 0, canvas_width, canvas_height,
      0, 0, canvas_width, canvas_height,
      ADD
    );
  }
 
  protected void renderPixel(PApplet canvas, LedPixel led_pixel) {
    color led_col = led_pixel.col & 0xFFFFFF; // Mask out the alpha
    
    // Create the image of the pixel with falloff (in the alpha channel).
    intensity_image.loadPixels();
    for(int i = 0; i < intensity_map.length; i++) {
      int intensity = (int)(intensity_map[i] * 255);
      intensity_image.pixels[i] = intensity << 24 | led_col;
    }
    intensity_image.updatePixels();

    // Render the image to the canvas, with alpha.
    int left = (int)led_pixel.canvas_position.x - INTENSITY_MAP_SIZE / 2;
    int top = (int)led_pixel.canvas_position.y - INTENSITY_MAP_SIZE / 2;
    canvas.blend(intensity_image,
      0, 0, INTENSITY_MAP_SIZE, INTENSITY_MAP_SIZE, // Source x,y, width, height
      left, top, INTENSITY_MAP_SIZE, INTENSITY_MAP_SIZE, // Dest x,y, width, height
      ADD
    );
  }
}

public class SimWindow extends PApplet {
  boolean is_window_positioned = false;
  Simulation simulation;
  int canvas_width, canvas_height;
  
  SimWindow(Simulation simulation, int canvas_width, int canvas_height) {
    super();
    this.simulation = simulation;
    this.canvas_width = canvas_width;
    this.canvas_height = canvas_height;
  }
    
  public void settings() {
    size(canvas_width, canvas_height);
  }

  public void setup() {
    fill(64);
  }

  public void draw() {
    if(!is_window_positioned) {
      // Place this side by side with the main window.
      surface.setLocation(canvas_width, 200);
      is_window_positioned = true;
    }
    simulation.render(this);
  }
}
