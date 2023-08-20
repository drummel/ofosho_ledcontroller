/**
 * Initializes the Shapes array.
 */

import org.ejml.simple.*; 

final float LETTER_WIDTH_INCHES = 20.0;
final float BLOCK_SIZE_INCHES = LETTER_WIDTH_INCHES / 4.0; // inches. width/height of one plastic "pixel" on the letters.


char[] letter_names = { 'O', 'F', 'O', 'S', 'H', 'O' };  // Mainly used for debugging
float[] letter_x_offsets_inches = {
  // Where each letter is positioned horizontally in the physical world (in inches)
  0.0, // O
  22.0, // F
  44.0, // O
  66.0, // S
  88.0, // H
  110.0, // O
};
String[] pixel_masks = {
  // Used in the simulator to place a crude shape of the letter. Each string is a flattened 4x6 pixel representation of an
  // OFOSHO letter (reading in the same order as the LEDs, i.e. start at bottom right moving left, then up, right 4 LEDs, up, left, etc.
  // X means pixel on, _ means pixel off.
  "_XX_ X__X X__X X__X X__X _XX_", // O
  "___X X___ ___X XXXX ___X XXXX", // F
  "_XX_ X__X X__X X__X X__X _XX_", // O
  "_XXX ___X X___ _XX_ ___X _XXX", // S
  "X__X X__X X__X XXXX X__X X__X", // H
  "_XX_ X__X X__X X__X X__X _XX_", // O
};
int[] letter_opc_base_id = {
  // The OPC ID of the first pixel in each letter.
  0,   // O
  24,  // F
  48,  // O
  72,  // S
  96,  // H
  120, // O
};


/*
  Initializes the Shapes data structure.
*/
public class InitShapes {
  public Shapes initializeShapes()
  {
    Shapes shapes = new Shapes();
    shapes.scale = 0.9;
    shapes.shapes = new ArrayList();
    for(int i = 0; i < 6; i++) {
      shapes.shapes.add(createShape(i));
    }

    shapes.world_to_canvas = getWorldToCanvasMatrix(shapes);
    xformLedsToCanvasSpace(shapes);
    
    shapes.all_leds = new ArrayList<LedPixel>();
    for(Shape shape : shapes.shapes) {
      for(LedPixel led: shape.leds) {
        shapes.all_leds.add(led);
      }
    }
    return shapes;
  }
  
  protected Shape createShape(int shape_index)
  {
    Shape shape = new Shape();
    shape.letter = letter_names[shape_index];
    shape.world_offset = new PVector(letter_x_offsets_inches[shape_index], 0.0);
    shape.rotation = 0.0;

    // Each string of LEDs is arranged in the following pattern, looking at the front:
    //
    // X----X----X----X (23)
    // |
    // X----X----X----X (16)
    //                |
    // X----X----X----X (15)
    // |
    // X----X----X----X (8)
    //                |
    // X----X----X----X (7)
    // |
    // X----X----X----X (0)
    //
    // This code will generate the LEDs in those positions, relative to the letter's own coordinate system. (+X is right, +Y is up)
    // These are later translated into the world coordinate system.
    int opc_index_base = letter_opc_base_id[shape_index];
    shape.leds = new ArrayList();
    float y_position = 0.0;
    float x_position = LETTER_WIDTH_INCHES;   // Start on the right
    float x_direction = -1.0;  // Start out moving left.
    int col_count = 0;
    int pixel_mask_idx = 0;
    for(int i = 0; i < 24; i++) { // 24 LEDs in each string
      LedPixel pixel = new LedPixel();
      pixel.shape_position = new PVector(x_position, y_position);
      pixel.opc_index = opc_index_base + i;
      pixel.col = color(0, 0, 0);
      while(pixel_masks[shape_index].charAt(pixel_mask_idx) == ' ') { // Skip spaces added to make the string more legible
        pixel_mask_idx++;
      }
      pixel.is_visible = (pixel_masks[shape_index].charAt(pixel_mask_idx++) == 'X');

      shape.leds.add(pixel);

      if (++col_count >= 4) { // 4 LEDs per row, so when we reach 4 we move to the next row and switch direction.
        col_count = 0;
        x_direction = -x_direction;
        y_position += LETTER_WIDTH_INCHES / 4.0;
      } else {
        x_position += x_direction * (LETTER_WIDTH_INCHES / 4.0);
      }
    }
    return shape;
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
    // Find a bounding box that contains all the shapes.
    BoundingBox bounding_box = new BoundingBox();

    for(Shape shape: shapes.shapes) {
      SimpleMatrix shape_to_world = shape.getShapeToWorldMatrix();
      
      // Calculate the world coords of each pixel in the shape, and merge it with the current bounding box.
      for(LedPixel pixel: shape.leds) {
        PVector world_coords = LinearXforms.multMatrixByPVector(shape_to_world, pixel.shape_position);
        bounding_box.addValue(world_coords);
      }
    }
    return bounding_box;
  }
}
