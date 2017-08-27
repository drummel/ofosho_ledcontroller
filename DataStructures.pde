final float BLOCK_SIZE = 9.6; // inches. width/height of one plastic "pixel" on the letters.
final int GRID_WIDTH = 3;
final int GRID_HEIGHT = 5;

public class LedPixel {
  PVector shape_position;   // Position of pixel relative to bottom left of shape, in inches. NOTE: +X right, +Y is UP
  PVector canvas_position;  // Position of pixe4l relative to the top left display canvas, in pixels. +X right, +Y DOWN.
  int opc_index;            // The unique number used by the OPC library to refer to this pixel.
  color col;                // Current color
}

public class Shape {
  char letter; // The letter that this Shape represents (mostly used for debugging)
  PVector world_offset; // Offset of this letter's bottom left corner in world coords. +X right, +Y is UP.
  float rotation; // in Radians, clockwise, around top/left.
  boolean[][] grid; // 5 (outer) x 3 (inner) array describing whether there is plastic at that position. (bottom row is first)
  List<LedPixel> leds;  // List of LedPixel objects
  
  /**
   * Returns a 3x3 LinearXformation that will map an LED shape position into world coords.
   */
  public SimpleMatrix getShapeToWorldMatrix() {
    SimpleMatrix letter_rotate = LinearXforms.rotate(rotation);
    SimpleMatrix to_world = LinearXforms.translate(world_offset.x, world_offset.y);
    return to_world.mult(letter_rotate);
  } 
}

public class Shapes {
  List<Shape> shapes;
  float scale;
  SimpleMatrix world_to_canvas;
}