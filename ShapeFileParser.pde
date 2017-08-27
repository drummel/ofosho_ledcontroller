import java.util.*;


class ShapeParseException extends Exception {
  ShapeParseException(String message, Throwable cause) {
    super(message, cause);
  }
}


/**
 * Reads a shape_description file and parses it into the Shapes object.
 */
public class ShapeFileParser {
  public Shapes parseFile(String filename)
  throws ShapeParseException
  {
    JSONObject json = loadFile(filename);
    return parseShapes(json); 
  }

  protected JSONObject loadFile(String filename)
  throws ShapeParseException
  {
    try {
      return loadJSONObject(filename);
    } catch (Exception e) {
      throw new ShapeParseException("Couldn't load data file: " + filename, e);
    }
  }
  
  protected Shapes parseShapes(JSONObject json)
  throws ShapeParseException
  {
    Shapes shapes = new Shapes();
    shapes.scale = json.getFloat("scale");
    shapes.shapes = new ArrayList();
  
    JSONArray json_shapes = json.getJSONArray("shapes");
    for(int i = 0; i < json_shapes.size(); i++) {      
      try {
        JSONObject json_shape = json_shapes.getJSONObject(i);
        shapes.shapes.add(parseShape(json_shape));
      } catch (Exception e) {
        throw new ShapeParseException("Error processing shape index: " + i, e);
      }
    }
    return shapes;
  }

  protected Shape parseShape(JSONObject json_shape)
  throws ShapeParseException
  {
      char letter = json_shape.getString("letter").charAt(0);
      float world_x = json_shape.getFloat("world_x");
      float world_y = json_shape.getFloat("world_y");
      float rotation = json_shape.getFloat("rotation");
      int opc_index_base = json_shape.getInt("opc_index_base");
      String grid = json_shape.getString("grid");
      JSONArray json_leds = json_shape.getJSONArray("leds");
      List leds = parseLeds(json_leds, opc_index_base);

      Shape shape = new Shape();
      shape.letter = letter;
      shape.world_offset = new PVector(world_x, world_y);
      shape.rotation = rotation;
      shape.leds = leds;
      shape.grid = new boolean[GRID_HEIGHT][GRID_WIDTH];
      int i = 0;
      for(int y = 0; y < GRID_HEIGHT; y++) {
        for(int x = 0; x < GRID_WIDTH; x++) {
          shape.grid[y][x] = (grid.charAt(i++) == 'X');
        }
      }
      return shape;
  }
  /**
   * @param opc_index_base - the first LED pixel's address as seen by FadeCandy
   */
  protected List parseLeds(JSONArray json_leds, int opc_index_base)
  throws ShapeParseException
  {
    List leds = new ArrayList();
    for(int i = 0; i < json_leds.size(); i++) {
      try {
        JSONObject json_led = json_leds.getJSONObject(i);
        float led_x = json_led.getFloat("x");
        float led_y = json_led.getFloat("y");
        LedPixel pixel = new LedPixel();
        pixel.shape_position = new PVector(led_x, led_y);
        pixel.opc_index = opc_index_base + i;
        pixel.col = 0;
        leds.add(pixel);
      } catch (Exception e) {
        throw new ShapeParseException("Error parsing LED index: " + i, e);
      }
    }
    return leds;
  }
}