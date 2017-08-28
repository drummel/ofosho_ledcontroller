public class Fire {
  double intensity[][];
  color[] palette;
  final int FIRE_WIDTH = CANVAS_WIDTH / 4;
  final int FIRE_HEIGHT = CANVAS_HEIGHT / 4;
  
  Fire()
  {
    intensity = new double[FIRE_HEIGHT][FIRE_WIDTH];
    for(int y = 0; y < FIRE_HEIGHT; y++) {
      for(int x = 0; x < FIRE_WIDTH; x++) {
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
    for(int x = 0; x < FIRE_WIDTH; x++) {
      intensity[FIRE_HEIGHT - 1][x] = Math.random() * 256.0;
    }
   
    for(int y = 0; y < FIRE_HEIGHT - 1; y++) {
      for(int x = 1; x < FIRE_WIDTH - 1; x++) {
        intensity[y][x] =
          (
            //intensity[y][x] +
            intensity[y+1][x-1] +
            intensity[y+1][x] +
            intensity[y+1][x+1] +
            intensity[(y+2) % FIRE_HEIGHT][x]
          ) / 4.08;
      }
    }
  }
  
  // X Y of the canvas
  color getColorAtXY(int x, int y) {
    int fx = (int)(x * FIRE_WIDTH / CANVAS_WIDTH);
    int fy = (int)(y * FIRE_HEIGHT / CANVAS_HEIGHT);
    return palette[(int)intensity[fy][fx]];
  }
}

public class FireCanvasEffect extends CanvasEffect {
  Fire fire;
  FireCanvasEffect(EffectUtils utils, Fire fire)
  {
    super(utils);
    this.fire = fire;
  }
  
  void render() {
    fire.initFrame();
    utils.loadPixels();
    for(int y = 0 ; y < CANVAS_HEIGHT; y++) {
      for(int x = 0; x < CANVAS_WIDTH; x++) {
        utils.setPixel(x, y, fire.getColorAtXY(x, y));
      }
    }
    utils.updatePixels();
  }
}

public class FirePointEffect extends PointEffect {
  Fire fire;
  FirePointEffect(EffectUtils utils, Fire fire)
  {
    super(utils);
    this.fire = fire;
  }
  
  void render() {
    fire.initFrame();
    for(LedPixel led_pixel: utils.leds) {
      led_pixel.col = fire.getColorAtXY((int)led_pixel.canvas_position.x, (int)led_pixel.canvas_position.y);
    }
  }
}