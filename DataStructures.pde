final float BLOCK_SIZE = 9.6; // inches. width/height of one plastic "pixel" on the letters.
final int GRID_WIDTH = 3;
final int GRID_HEIGHT = 5;


/*
  Represents a single FadeCandy LED pixel.
*/
public class LedPixel {
  PVector shape_position;   // Position of pixel relative to bottom left of it's Shape, in inches. NOTE: +X right, +Y is UP
  PVector canvas_position;  // Position of pixel relative to the top left display canvas, in pixels. +X right, +Y DOWN.
  int opc_index;            // The unique number used by the OPC library to refer to this pixel.
  color col;                // Current color
}


/*
  A Shape represents positional data about one of the 6 letters in "OFOSHO".
*/
public class Shape {
  char letter; // The letter that this Shape represents (mostly used for debugging)
  PVector world_offset; // Offset of this letter's bottom left corner in world coords. +X right, +Y is UP.
  List<LedPixel> leds;  // List of LedPixel objects belonging to this Shape

  float rotation; // in Radians, clockwise, around top/left.
  boolean[][] grid; // 5 (outer) x 3 (inner) array describing whether there is plastic at that position. (bottom row is first)

  /**
   * Returns a 3x3 LinearXformation that will map an LED shape position into world coords.
   */
  public SimpleMatrix getShapeToWorldMatrix() {
    SimpleMatrix letter_rotate = LinearXforms.rotate(rotation);
    SimpleMatrix to_world = LinearXforms.translate(world_offset.x, world_offset.y);
    return to_world.mult(letter_rotate);
  }
}


/*
  Contains the 6 Shapes that make up the OFOSHO letters
*/
public class Shapes {
  List<Shape> shapes;
  List<LedPixel> all_leds;  // Convenient access to any LED in any Shape
  float scale;
  SimpleMatrix world_to_canvas;

  // NB: there is no constructor here, initialization is handled in the InitShapes.pde file.
}
