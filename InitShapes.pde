/**
 * Initializes the Shapes array.
 */

import org.ejml.simple.*; 

// Utility class used to determine the bounds of a set of points
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

public class InitShapes {
  public Shapes initializeShapes(OPC opc)
  {
    Shapes shapes = loadShapes();

    shapes.world_to_canvas = getWorldToCanvasMatrix(shapes);
    xformLedsToCanvasSpace(shapes);
    
    for(Shape shape: shapes.shapes) {
      println("Initializing shape:" + Character.toString(shape.letter));
      for(LedPixel led_pixel: shape.leds) {
        opc.led(
          led_pixel.opc_index,
          (int)Math.floor(led_pixel.canvas_position.x),
          (int)Math.floor(led_pixel.canvas_position.y)
        );
        led_pixel.col = color(0);
      }
    }
    
    return shapes;
  }
  
  protected Shapes loadShapes()
  {
    try {
      return (new ShapeFileParser()).parseFile("shape_description.json");
    } catch (ShapeParseException e) {
      println(e);
      println(e.getCause());
      System.exit(1);
      // This is just here to satisfy the compiler
      return new Shapes();
    }
  }

  protected SimpleMatrix getWorldToCanvasMatrix(Shapes shapes) {
    BoundingBox world_bounding_box = getWorldBoundingBox(shapes);
    float world_width = world_bounding_box.right - world_bounding_box.left;
    float world_height = world_bounding_box.top - world_bounding_box.bottom;
 
    // First, work out the scale factor to fit the world box to the width of the canvas.
    float world_to_canvas_scale = (float)CANVAS_WIDTH / world_width;
    float new_world_height = world_to_canvas_scale * world_height;
    if(new_world_height > (float)CANVAS_HEIGHT) {
      // Won't fit inside the canvas this way. Scale it using the vertical height instead.
      world_to_canvas_scale = (float)CANVAS_HEIGHT / world_height;
    }
    
    // Move the shapes from wherever they are so that the bounding box is centered at the origin.
    SimpleMatrix center_shapes_around_origin = LinearXforms.translate(
      -(world_bounding_box.left + world_width / 2.0),
      -(world_bounding_box.bottom + world_height / 2.0)
    );
    // Scale the shapes so that they're equivalent to the canvas scale
    SimpleMatrix world_to_canvas_scale_matrix = LinearXforms.scale(world_to_canvas_scale, world_to_canvas_scale);
    // Scale the shapes again that they're squeezed in a little bit from the borders
    SimpleMatrix squeeze_in_matrix = LinearXforms.scale(shapes.scale, shapes.scale);
    // The world coordinate system is +Y = UP, but canvas is +Y = DOWN, so flip it and shift it.
    SimpleMatrix world_to_canvas_y_axis_flip = LinearXforms.scale(1.0, -1.0);
    SimpleMatrix world_to_canvas_translate = LinearXforms.translate((float)CANVAS_WIDTH / 2.0, (float)CANVAS_HEIGHT / 2.0);

    // Note: these are listed in reverse order in which the xformations will be performed.
    SimpleMatrix world_to_canvas =
      world_to_canvas_translate
      .mult(world_to_canvas_y_axis_flip
      .mult(squeeze_in_matrix
      .mult(world_to_canvas_scale_matrix
      .mult(center_shapes_around_origin
      ))));
    return world_to_canvas;
  }

  protected void xformLedsToCanvasSpace(Shapes shapes) {
    for(Shape shape: shapes.shapes) {
      SimpleMatrix shape_to_world = shape.getShapeToWorldMatrix();
      SimpleMatrix shape_to_canvas = shapes.world_to_canvas.mult(shape_to_world);
      for(LedPixel pixel: shape.leds) {
        pixel.canvas_position = LinearXforms.multMatrixByPVector(shape_to_canvas, pixel.shape_position);
        if (pixel.canvas_position.x >= CANVAS_WIDTH || pixel.canvas_position.x < 0) {
          throw new RuntimeException("Error: pixel x is out of screen bounds");
        } else if(pixel.canvas_position.y >= CANVAS_HEIGHT || pixel.canvas_position.y < 0) {
          throw new RuntimeException("Error: pixel y is out of screen bounds");
        }
      }
    }
  }
    
  protected BoundingBox getWorldBoundingBox(Shapes shapes) {  
    // Find the world_coords bounding box
    BoundingBox bounding_box = new BoundingBox();

    for(Shape shape: shapes.shapes) {
      SimpleMatrix shape_to_world = shape.getShapeToWorldMatrix();
      
      for(LedPixel pixel: shape.leds) {
        PVector world_coords = LinearXforms.multMatrixByPVector(shape_to_world, pixel.shape_position);
        bounding_box.addValue(world_coords);
      }

      // Also do the same for the 4 corners of the shape.
      for(int x = 0; x <= GRID_WIDTH; x += GRID_WIDTH) {
        for(int y = 0; y <= GRID_HEIGHT; y += GRID_HEIGHT) {   
          PVector world_coords = LinearXforms.multMatrixByPVector(shape_to_world, new PVector(x * BLOCK_SIZE, y * BLOCK_SIZE));
          bounding_box.addValue(world_coords);
        }
      }
    }
    return bounding_box;
  }
}