/**
 * This is a mini-tool to generate **approximate** values for the OFOSHO letter shapes. It will
 * save it to a file where the values can be easily tweaked manually to their actual values.
 * It's not meant to be run at runtime, instead just uncomment the call to it in the main
 * setup() function.
 */
 
// Call this from setup() to generate the file and then immediately exit.
void genShapeFile()
{
  String output_filename = "data/shape_description_new.json";
  (new ShapeFileGenerator()).genFile(output_filename);
  println("Successfully generated shape definition file: " + output_filename);
  System.exit(1);
} 

 
public class ShapeFileGenerator {
  public void genFile(String output_filename) {
    Shapes shapes = genShapes();
    
    ShapeFileRenderer renderer = new ShapeFileRenderer();
    renderer.renderToFile(shapes, output_filename);
  }
  
  protected Shapes genShapes() {
    Shapes shapes = new Shapes();
    shapes.scale = 0.9;
    shapes.shapes = new ArrayList();
    
    float horizontal_spacing = BLOCK_SIZE * 4; // Space between the bottom left edges of the letters, in inches
    String letters = "OFOSHO";
    float world_x = 0.0;
    
    for (int i = 0; i < letters.length(); i++, world_x += horizontal_spacing) {
      char c = letters.charAt(i);  
      ShapeBuilder builder = new ShapeBuilder(world_x, c);
      
      switch(c) {
        case 'O':
          builder.setLineBySubBlock(new PVector(0,0), new PVector(0, 4), 5, true, true);           // Left
          builder.setLineBySubBlock(new PVector(0,4), new PVector(2, 4), 3, false, true);          // Top
          builder.setLineBySubBlock(new PVector(2,4), new PVector(2, 0), 5, false, true);          // Right
          builder.setLineBySubBlock(new PVector(2,0), new PVector(0, 0), 3, false, false);         // Bottom
          builder.setGrid("XXX X_X X_X X_X XXX");
          break;
          
        case 'F':
          builder.setLineBySubBlock(new PVector(0,0), new PVector(0, 2), 3, true, true);
          builder.setLineBySubBlock(new PVector(0,2), new PVector(2, 2), 3, false, true);
          builder.setLineBySubBlock(new PVector(0,2), new PVector(0, 4), 3, false, true);
          builder.setLineBySubBlock(new PVector(0,4), new PVector(2, 4), 3, false, true);
          builder.setGrid("XXX X__ XXX X__ X__");
          break;
          
        case 'S':
          builder.setLineBySubBlock(new PVector(0,0), new PVector(2, 0), 3, true, true);
          builder.setLineBySubBlock(new PVector(2,0), new PVector(2, 2), 3, false, true);
          builder.setLineBySubBlock(new PVector(2,2), new PVector(0, 2), 3, false, true);
          builder.setLineBySubBlock(new PVector(0,2), new PVector(0, 4), 3, false, true);
          builder.setLineBySubBlock(new PVector(0,4), new PVector(2, 4), 3, false, true);
          builder.setGrid("XXX X__ XXX __X XXX");
          break;
          
        case 'H':
          builder.setLineBySubBlock(new PVector(0,0), new PVector(0, 4), 5, true, true);
          builder.setLineBySubBlock(new PVector(0,2), new PVector(2, 2), 3, false, false);
          builder.setLineBySubBlock(new PVector(2,0), new PVector(2, 4), 5, true, true);
          builder.setGrid("X_X X_X XXX X_X X_X");
          break;
          
        default:
          throw new RuntimeException("Unsupported letter: " + c);
      }
      shapes.shapes.add(builder.getShape());
    }
    return shapes;
  }
}

// ----------------------------------------------------------------------


/**
 * Class to assist in constructing a Shape object and populating it with LEDs.
 */
public class ShapeBuilder {
  Shape shape;
  ShapeBuilder(float world_x, char letter) {
    shape = new Shape();
    shape.letter = letter;
    shape.world_offset = new PVector(world_x, 0.0);
    shape.rotation = 0.0;
    shape.leds = new ArrayList();
  }
  
  Shape getShape() {
    return shape;
  }
  
  /**
   * Set the location of a single LED Pixel relative to the bottom left of the shape.
   * Units are in inches
   */
  void setNeoPixel(PVector pos) {
    LedPixel pixel = new LedPixel();
    pixel.shape_position = pos.copy();
    shape.leds.add(pixel);
  }

  /**
   * Set a line of LEDs.
   * @param include_first - true if the "start" position should have an LED placed there.
   * @param include_last - true if the "end" position should have an LED placed there.
   */
  void setLine(PVector start, PVector end, int num_leds, boolean include_first, boolean include_last) {
    PVector delta = end.copy();
    delta.sub(start);
    
    for(int i = 0; i < num_leds; i++) {
      if(i == 0 && !include_first) {
        continue;
      } else if(i == num_leds - 1 && !include_last) {
        continue;
      }
      PVector pos = delta.copy()
        .mult((float)i / (float)(num_leds - 1))
        .add(start);
      setNeoPixel(pos);
    }
  }

  /**
   * Each letter is a 3x5 block, like so:
   * [][][]
   * [][][]
   * [][][]
   * [][][]
   * [][][]
   *
   * This function lets the caller specify a line of LEDs by giving the position of LEDs in BLOCK coordinates.
   * (the bottom left is 0,0). The LEDs are assumed to be positioned in the center of each block.
   */
  void setLineBySubBlock(PVector start, PVector end, int num_leds, boolean include_first, boolean include_last) {
    PVector center_block = new PVector(BLOCK_SIZE / 2, BLOCK_SIZE / 2);
    start.mult(BLOCK_SIZE);
    end.mult(BLOCK_SIZE);
    start.add(center_block);
    end.add(center_block);
    setLine(start, end, num_leds, include_first, include_last);
  }
  
  /**
   * @param g - a string describing the letter grid. It consists of 5 x 3 chars (separated by spaces). X means there is plastic there, _ means
   * there is nothing. E.g. "XXX _X_ ..." means the top row has 3 blocks of plastic, the next row has an empty space, a block, and an empty space, etc.
   */
  void setGrid(String g)
  {
    shape.grid = new boolean[GRID_HEIGHT][GRID_WIDTH];
    int y = GRID_HEIGHT - 1;
    int x = 0;
    for(int i = 0; i < g.length(); i++) {
      if (g.charAt(i) == ' ') {
        continue;
      }
      if(y < 0) {
        throw new RuntimeException("Too many letters in the grid descriptor!");
      }
      shape.grid[y][x] = (g.charAt(i) == 'X');
      x++;
      if(x == GRID_WIDTH) {
        x = 0;
        y--;
      }
    }
  }
}

// ----------------------------------------------------------------------


/**
 * Renders the Shapes object to a JSON file
 */
public class ShapeFileRenderer {
  public void renderToFile(Shapes shapes, String filename) {
    JSONObject json = new JSONObject();
    json.setFloat("scale", shapes.scale);
    json.setJSONArray("shapes", renderShapeArray(shapes.shapes));
    
    saveJSONObject(json, filename, "indent=2");
  }
  
  protected JSONArray renderShapeArray(List<Shape> shapes) {
    JSONArray json_shapes = new JSONArray();
    int i = 0, opc_index_base = 0;
    for (Shape shape: shapes) {
      JSONObject json_shape = renderShape(shape, opc_index_base);
      json_shapes.setJSONObject(i++, json_shape);
      opc_index_base += 64;
    }
    return json_shapes; 
  }
  
  protected JSONObject renderShape(Shape shape, int opc_index_base) {
    JSONObject json_shape = new JSONObject();
 
    String grid = "";
    for(int y = 0; y < GRID_HEIGHT; y++) {
      for(int x = 0; x < GRID_WIDTH; x++) {
        grid += (shape.grid[y][x] ? "X" : "_");
      }
    }
 
    json_shape.setString("letter", Character.toString(shape.letter));
    json_shape.setFloat("world_x", shape.world_offset.x);
    json_shape.setFloat("world_y", shape.world_offset.y);
    json_shape.setFloat("rotation", shape.rotation);
    json_shape.setInt("opc_index_base", opc_index_base);
    json_shape.setString("grid", grid);
    
    JSONArray leds = new JSONArray();
    int i = 0;
    for(LedPixel led_pixel: shape.leds) {
      leds.setJSONObject(i++, renderLedPixel(led_pixel));
    }
    json_shape.setJSONArray("leds", leds);
    return json_shape;
  }
  
  protected JSONObject renderLedPixel(LedPixel led_pixel) {
    JSONObject json_led = new JSONObject();
    json_led.setFloat("x", led_pixel.shape_position.x);
    json_led.setFloat("y", led_pixel.shape_position.y);
    return json_led;
  }
}