class Plasma {
  protected double[][] plasma1, plasma2;
  protected int[] sx, sy;
  Plasma()
  {
    plasma1 = new double[CANVAS_HEIGHT * 2][CANVAS_WIDTH * 2];
    plasma2 = new double[CANVAS_HEIGHT * 2][CANVAS_WIDTH * 2];
    sx = new int[3];
    sy = new int[3];
    for(int y = 0; y < CANVAS_HEIGHT * 2; y++) {
      int delta_y = CANVAS_HEIGHT - y;
      for(int x = 0; x < CANVAS_WIDTH * 2; x++) {
        int delta_x = CANVAS_WIDTH - x;
        plasma1[y][x] = 128.0 + 127.0 * Math.cos(Math.hypot(delta_x, delta_y) / 100.0);
        plasma2[y][x] = 128.0 + 127.0 * Math.sin(Math.hypot(delta_x, delta_y) / 100.0);
      }
    }
  }

  void initFrame(int frame_num) {
    float time = (float)frame_num;
    sx[0] = (CANVAS_WIDTH + (int)( (CANVAS_WIDTH - 2) * Math.sin(time / 137.0))) / 2;
    sx[1] = (CANVAS_WIDTH + (int)( (CANVAS_WIDTH - 2) * Math.sin(-time / 125.0))) / 2;
    sx[2] = (CANVAS_WIDTH + (int)( (CANVAS_WIDTH - 2) * Math.sin(-time / 123.0))) / 2;
    sy[0] = (CANVAS_HEIGHT + (int)( (CANVAS_HEIGHT - 2) * Math.cos(time / 123.0))) / 2;
    sy[1] = (CANVAS_HEIGHT + (int)( (CANVAS_HEIGHT - 2) * Math.cos(-time / 85.0))) / 2;
    sy[2] = (CANVAS_HEIGHT + (int)( (CANVAS_HEIGHT - 2) * Math.cos(-time / 108.0))) / 2;
  }
  
  color getColorAtXY(int x, int y) {
    return color(
        (int)plasma2[sy[0] + y][sx[0] + x],
        (int)plasma1[sy[1] + y][sx[1] + x],
        (int)plasma2[sy[2] + y][sx[2] + x]
      );
  }
}

public class PlasmaCanvasEffect extends CanvasEffect {
  Plasma plasma;
  PlasmaCanvasEffect(EffectUtils utils, Plasma plasma)
  {
    super(utils);
    this.plasma = plasma;
  }
  
  void render() {
    utils.loadPixels();
    plasma.initFrame(utils.frame_num);
    
    for(int y = 0 ; y < CANVAS_HEIGHT; y++) {
      for(int x = 0 ; x < CANVAS_WIDTH; x++) {
        utils.setPixel(x, y, plasma.getColorAtXY(x, y));
      }
    }
    utils.updatePixels();
  }
}

public class PlasmaPointEffect extends PointEffect {
  Plasma plasma;
  PlasmaPointEffect(EffectUtils utils, Plasma plasma)
  {
    super(utils);
    this.plasma = plasma;
  }
  
  void render() {
    plasma.initFrame(utils.frame_num);
    for(LedPixel led_pixel: utils.leds) {
      led_pixel.col = plasma.getColorAtXY((int)led_pixel.canvas_position.x, (int)led_pixel.canvas_position.y);
    }
  }
}