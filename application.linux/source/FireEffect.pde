/*
 This class manages the virtual canvas that the fire effect uses. See initFrame for an explanation
 of how the effect works.
*/
public class Fire {
  double intensity[][];
  color[] palette;
  int canvas_width, canvas_height;
  int fire_width, fire_height;
  
  Fire(int canvas_width, int canvas_height)
  {
    this.canvas_width = canvas_width;
    this.canvas_height = canvas_height;
    this.fire_width = canvas_width / 4;
    this.fire_height = canvas_height / 4;
    intensity = new double[fire_height][fire_width];
    for(int y = 0; y < fire_height; y++) {
      for(int x = 0; x < fire_width; x++) {
        intensity[y][x] = 0;
      }
    }
    
    palette = new color[256];
    for(int x = 0; x < palette.length; x++) {
      //HSLtoRGB is used to generate colors:
      //Hue goes from 0 to 85: red to yellow
      //Saturation is always the maximum: 255
      //Lightness is 0..255 for x=0..128, and 255 for x=128..255
      palette[x] = Color.HSBtoRGB(x / (4.5 * 255.0), 1.0, Math.min(1.0, x*2 / 255.0));
    }
  }
  
  void initFrame() {
    // We write random high intensity values to the bottom row of the grid (the "fire").
    for(int x = 0; x < fire_width; x++) {
      intensity[fire_height - 1][x] = Math.random() * 256.0;
    }
 
    // This pixels in each row above the "fire" is the average of its neighboring pixels. This
    // naturally attenuates the intensity the higher we go.
    for(int y = 0; y < fire_height - 1; y++) {
      for(int x = 1; x < fire_width - 1; x++) {
        intensity[y][x] =
          (
            //intensity[y][x] +
            intensity[y+1][x-1] +
            intensity[y+1][x] +
            intensity[y+1][x+1] +
            intensity[(y+2) % fire_height][x]
          ) / 4.02; // made this a bit brighter for LEDs
      }
    }
  }
  
  // X Y of the canvas
  color getColorAtXY(int x, int y) {
    int fx = (int)(x * fire_width / canvas_width);
    int fy = (int)(y * fire_height / canvas_height);
    return palette[(int)intensity[fy][fx]];
  }
}


/*
 This effect renders the Fire effect to the entire canvas by copying
 it from the virtual canvas in Fire().
*/
public class FireCanvasEffect extends CanvasEffect {
  Fire fire;
  FireCanvasEffect(Fire fire)
  {
    super();
    this.fire = fire;
  }
  
  void render(CanvasPainter painter, Shapes shapes, int frame_num) {
    fire.initFrame();
    for(int y = 0 ; y < painter.canvas_height; y++) {
      for(int x = 0; x < painter.canvas_width; x++) {
        painter.setPixel(x, y, fire.getColorAtXY(x, y));
      }
    }
  }
}


/*
  This effect renders the Fire class's effect to only the points used by the LEDs.
  It's computationally cheaper (marginally) than the Canvas version.
*/
public class FirePointEffect extends PointEffect {
  Fire fire;
  FirePointEffect(Fire fire)
  {
    super();
    this.fire = fire;
  }
  
  void render(CanvasPainter painter, Shapes shapes, int frame_num) {
    fire.initFrame();
    for(LedPixel led_pixel: shapes.all_leds) {
      painter.setLedPixel(led_pixel, fire.getColorAtXY((int)led_pixel.canvas_position.x, (int)led_pixel.canvas_position.y));
    }
  }
}
