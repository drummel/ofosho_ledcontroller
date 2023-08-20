/*
 The plasma effect is a smooth fluid gradiant across the entire canvas.
 
 It works by pre-calculating some off-screen buffers that contain smooth height maps for an area twice the size
 of the main canvas. During the animation phase, it smoothly animates 3 points over these height maps.
 The RGB of a given pixel are the values of the heightmaps, offset by the position of the moving points.
*/
class Plasma {
  protected double[][] plasma1, plasma2;
  protected int[] sx, sy;
  int canvas_width, canvas_height;

  Plasma(int canvas_width, int canvas_height)
  {
    this.canvas_width = canvas_width;
    this.canvas_height = canvas_height;
    plasma1 = new double[canvas_height * 2][canvas_width * 2];
    plasma2 = new double[canvas_height * 2][canvas_width * 2];
    sx = new int[3];
    sy = new int[3];
    for(int y = 0; y < canvas_height * 2; y++) {
      int delta_y = canvas_height - y;
      for(int x = 0; x < canvas_width * 2; x++) {
        int delta_x = canvas_width - x;
        plasma1[y][x] = 128.0 + 127.0 * Math.cos(Math.hypot(delta_x, delta_y) / 100.0);
        plasma2[y][x] = 128.0 + 127.0 * Math.sin(Math.hypot(delta_x, delta_y) / 100.0);
      }
    }
  }

  void initFrame(int frame_num) {
    float time = (float)frame_num;
    sx[0] = (canvas_width + (int)( (canvas_width - 2) * Math.sin(time / 137.0))) / 2;
    sx[1] = (canvas_width + (int)( (canvas_width - 2) * Math.sin(-time / 125.0))) / 2;
    sx[2] = (canvas_width + (int)( (canvas_width - 2) * Math.sin(-time / 123.0))) / 2;
    sy[0] = (canvas_height + (int)( (canvas_height - 2) * Math.cos(time / 123.0))) / 2;
    sy[1] = (canvas_height + (int)( (canvas_height - 2) * Math.cos(-time / 85.0))) / 2;
    sy[2] = (canvas_height + (int)( (canvas_height - 2) * Math.cos(-time / 108.0))) / 2;
  }
  
  color getColorAtXY(int x, int y) {
    return color(
        (int)plasma2[sy[0] + y][sx[0] + x],
        (int)plasma1[sy[1] + y][sx[1] + x],
        (int)plasma2[sy[2] + y][sx[2] + x]
      );
  }
}


/*
  This effect copies the Plasma class's virtual canvas to the main canvas.
*/
public class PlasmaCanvasEffect extends CanvasEffect {
  Plasma plasma;
  PlasmaCanvasEffect(Plasma plasma)
  {
    super();
    this.plasma = plasma;
  }
  
  void render(CanvasPainter painter, Shapes shapes, int frame_num) {
    plasma.initFrame(frame_num);
    for(int y = 0 ; y < painter.canvas_height; y++) {
      for(int x = 0 ; x < painter.canvas_width; x++) {
        painter.setPixel(x, y, plasma.getColorAtXY(x, y));
      }
    }
  }
}


/*
  This effect renders the Plasma class's effect to only the points used by the LEDs.
  It's computationally cheaper (marginally) than the Canvas version.
*/
public class PlasmaPointEffect extends PointEffect {
  Plasma plasma;
  PlasmaPointEffect(Plasma plasma)
  {
    super();
    this.plasma = plasma;
  }
  
  void render(CanvasPainter painter, Shapes shapes, int frame_num) {
    plasma.initFrame(frame_num);
    for(LedPixel led_pixel: shapes.all_leds) {
      painter.setLedPixel(led_pixel, plasma.getColorAtXY((int)led_pixel.canvas_position.x, (int)led_pixel.canvas_position.y));
    }
  }
}
