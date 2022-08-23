import java.util.List;

/*
  Represents a single FadeCandy LED pixel.
*/
public class LedPixel {
  PVector shape_position;   // Position of pixel relative to bottom left of it's Shape, in inches. NOTE: +X right, +Y is UP
  PVector canvas_position;  // Position of pixel relative to the top left display canvas, in pixels. +X right, +Y DOWN.
  int opc_index;            // The unique number used by the OPC library to refer to this pixel.
  color col;                // Current color
  boolean is_visible;       // Is this pixel directly visible through the plastic? (Dictates whether a crude diffuse square is drawn over this LED).
}


/*
  A Shape represents positional data about one of the 6 letters in "OFOSHO".
*/
public class Shape {
  char letter; // The letter that this Shape represents (mostly used for debugging)
  PVector world_offset; // Offset of this letter's bottom left corner in world coords. +X right, +Y is UP.
  List<LedPixel> leds;  // List of LedPixel objects belonging to this Shape
  float rotation; // in Radians, clockwise, around top/left.

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


/*
  Utility class used to determine the bounds of a set of points
*/
public class BoundingBox {
  float left, top, right, bottom;
  boolean has_value = false;

  void addValue(PVector p) {
    if (!has_value || left > p.x) {
      left = p.x;
    }
    if (!has_value || right < p.x) {
      right = p.x;
    }
    if (!has_value || top < p.y) {
      top = p.y;
    }
    if (!has_value || bottom > p.y) {
      bottom = p.y;
    }
    has_value = true;
  }

  String toString() {
    return "Left: " + left + "  Right: " + right + "  Top: " + top + "  Bottom: " + bottom;
  }
}
