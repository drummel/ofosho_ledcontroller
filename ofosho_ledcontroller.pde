/**
 * This is the "main" file.
 */

OPC opc;
PImage dot;
SimWindow simulation_window;

Shapes shapes;
boolean window_location_set = false;
final int screen_width = 640;
final int screen_height = 360;

void settings() {
  size(screen_width, screen_height);
}

void setup()
{
  String[] args = {"TwoFrameTest"};
  simulation_window = new SimWindow();
  PApplet.runSketch(args, simulation_window);

  
  // This is commented out as it's not normally supposed to be run. We add it in here just for convenience because
  // Processing makes it harder to make multiple application entry points. If it's uncommented, it just generates
  // a basic shapes_description.json file and exits immediately.
  // genShapeFile();
  
  // Connect to the local instance of fcserver
  opc = new OPC(this, "127.0.0.1", 7890);
  shapes = (new InitShapes()).initializeShapes(opc);

  // Load a sample image
  dot = loadImage("dot.png");
  
  /*
  // Map an 8x8 grid of LEDs to the center of the window
  opc.ledGrid8x8(0, width/2, height/2, height / 12.0, 0, false);
  */
}

void draw()
{
  background(0);
  if(!window_location_set) {
    surface.setLocation(0,200);
    window_location_set = true;
  }

  // Draw the image, centered at the mouse location
  float dotSize = height * 0.7;
  image(dot, mouseX - dotSize/2, mouseY - dotSize/2, dotSize, dotSize);
}

/**
 * This is not normally called. It's used to generate a shape description file.
 */
void genShapeFile()
{
  String output_filename = "data/shape_description_new.json";
  (new ShapeFileGenerator()).genFile(output_filename);
  println("Successfully generated shape definition file: " + output_filename);
  exit();
}
  