/**
 * Class to generate images used as masks which indicate the boundaries of where the plastic shapes of the letters are.
 * These are used to (a) highlight where the plastic is, and (b) black-out any screen areas where there is no plastic.
 */
public class PlasticMask {
  PGraphics mask;  // Image same size as canvas. Where there is plastic, the color is white, alpha is set to a small value.
                // This is blended onto the final image to indicate where the plastic is.
  PGraphics inverse_mask; // Same as above, but the inverse, and alpha is 255. blended with the simulation window to black-out any areas outside the plastic.

  PlasticMask(Shapes shapes)
  {
    /**
     * The mask dictates what pixels will be written to the screen. These in turn are dicated by what pieces of plastic cover
     * the LEDs. We generate the mask by drawing the "plastic" to the window using the quad() method, then using the color values
     * of the pixels in the window to make the mask. This drawing is only done once on initialization, and then is thrown away.
     */
    mask = createCanvas();
    inverse_mask = createCanvas();
 
    // For each shape, render the grid of plastic to the screen.
    for(Shape shape: shapes.shapes) {
      SimpleMatrix shape_to_world = shape.getShapeToWorldMatrix();
      SimpleMatrix shape_to_canvas = shapes.world_to_canvas.mult(shape_to_world);
      for(int y = 0; y < GRID_HEIGHT; y++) {
        for(int x = 0; x < GRID_WIDTH; x++) {
          if(!shape.grid[y][x]) {
            continue;
          }
          PVector[] quad_points = new PVector[4];
          for(int yy = 0; yy < 2; yy++) {
            for(int xx = 0; xx < 2; xx++) {
              quad_points[yy * 2 + xx] = LinearXforms.multMatrixByPVector(
                shape_to_canvas,
                new PVector((x + xx) * BLOCK_SIZE, (y + yy) * BLOCK_SIZE)
              );
            }
          }
          mask.quad(
            quad_points[0].x, quad_points[0].y,
            quad_points[1].x, quad_points[1].y,
            quad_points[3].x, quad_points[3].y,
            quad_points[2].x, quad_points[2].y
          );
        }
      }
    }
    mask.endDraw();
    inverse_mask.endDraw();
    
    mask.loadPixels();  // Ensure the written quads are loaded into the pixels[] array.
    inverse_mask.loadPixels();
    for(int i = 0; i < mask.pixels.length; i++) {
      mask.pixels[i] = (20 << 24) | (mask.pixels[i] & 0xFFFFFF);
      inverse_mask.pixels[i] = ((mask.pixels[i] & 0xFF) == 0) ? color(255,255,255,255) : color(0,0,0,0);
    }
    mask.updatePixels();
    inverse_mask.updatePixels();
  }

  protected PGraphics createCanvas()
  {
    PGraphics canvas = createGraphics(CANVAS_WIDTH, CANVAS_HEIGHT);
    canvas.beginDraw();
    canvas.background(0, 0);
    canvas.stroke(255.0, 255.0);
    canvas.fill(255.0, 255.0);
    return canvas;
  }
}