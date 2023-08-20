import java.awt.Color;


/*
 All animation Effects implement this interface.
*/
interface IEffect {
  /*
    Called when the EffectsController changes effects. Gives the effect an opportunity to re-initialize any
    internal settings.
  */
  void reset(Shapes shapes);

  /*
    Called every animation frame. Should render the colors to the canvas.

    @param CanvasPainter painter - used to read/write the pixels and LED colors easily.
    @param int frame_num - the animation frame number. Increments every animation frame.
  */
  void render(CanvasPainter painter, Shapes shapes, int frame_num);
}


/**
 A Canvas effect is where the effect draw the entire canvas, and then the LED color values are sampled
 from certain points on the canvas.
*/
public abstract class CanvasEffect implements IEffect {
  void reset(Shapes shapes) {}
}


/**
 A PointEffect's render() loop calculates and sets each LED's color explicitly using setLedPixel().

 This is used either because the effect is centered around the LEDs themselves (such as an effect where LEDs "chase"
 each other), or because it's computationally cheaper than rendering the entire canvas.
*/
public abstract class PointEffect implements IEffect {
  void reset(Shapes shapes) {}
}


/*
 This effect lights up each LED in sequence, as if each letter is being hand drawn. (This effect only makes
 sense if the LEDs are arranged to follow the shape of each letter)
*/

public class LetterWriter extends PointEffect {
  int offset = 0;
  int frame_delay = 0;

  void reset(Shapes shapes) {
    offset = shapes.all_leds.size() * 2;
    frame_delay = 0;
  }
  
  void render(CanvasPainter painter, Shapes shapes, int frame_num) {
    frame_delay = (frame_delay + 1) % 3;
    if (frame_delay == 0) {
      offset = (offset + 1) % (shapes.all_leds.size() * 2);
    }
    int i = offset;
    for(LedPixel led_pixel: shapes.all_leds) {
      if (i <= 0 || i > shapes.all_leds.size()) {
        painter.setLedPixel(led_pixel, color(0));
      } else {
        painter.setLedPixel(led_pixel, Color.HSBtoRGB((float)(i + frame_num) / 255.0, 1.0, 1.0));
      }
      i--;
    }
  }
}


/*
 This effect simulates the old-style marquee lights; Some lit LEDs are neighbored by dark LEDs, and their position
 shifts by one each frame, making it look like the lit LEDs are moving along the strip.
*/
public class BulbChaser extends PointEffect {
  float[] led_luminosity;
  int sub_frame;
  int frame_delay;

  void reset(Shapes shapes) {
    led_luminosity = new float[shapes.all_leds.size()];
    for(int i = 0; i < led_luminosity.length; i++) {
      led_luminosity[i] = 0;
    }
    sub_frame = 0;
    frame_delay = 0;
  }

  void render(CanvasPainter painter, Shapes shapes, int frame_num) {
    frame_delay = (frame_delay + 1) % 5;
    if (frame_delay == 0) {
      sub_frame++;
    }
    int s = sub_frame;
    int i = 0;
    for(LedPixel led_pixel: shapes.all_leds) {
      if (s % 6 < 3) {
        led_luminosity[i] = Math.max(0, led_luminosity[i] - 0.5);
      } else {
        led_luminosity[i] = 1.0;
      }
      painter.setLedPixel(led_pixel, Color.HSBtoRGB(36.0 / 255.0, 1.0, led_luminosity[i]));  // A Hue of 36/255 is Yellow.
      s++;
      i++;
    }
  }
}


/*
 Paints the entire canvas with the full color spectrum, moving horizontally.
*/
public class Rainbow extends CanvasEffect {
  void render(CanvasPainter painter, Shapes shapes, int frame_num) {
    for(int x = 0; x < painter.canvas_width; x++) {
      color col = Color.HSBtoRGB(((frame_num + x) & 0xFF) / 255.0, 1.0, 1.0);
      for(int y = 0; y < painter.canvas_height; y++) {
        painter.setPixel(x, y, col);
      }
    }
  }
}

/*
 Paints the entire canvas with the full color spectrum, moving horizontally.
*/
public class RainbowRandom extends CanvasEffect {
  float hue_offset;
  float n_renders = 0;
  
  RainbowRandom() {
    this.hue_offset = random(0,1);
  }
  
  void reset() {
     this.hue_offset = this.hue_offset + random(0,0.02);
  }
    
  void render(CanvasPainter painter, Shapes shapes, int frame_num) {
    for(int x = 0; x < painter.canvas_width; x++) {
      float hue = ((frame_num + x) & 0xFF) / 2000.0 + hue_offset;
      //hue = hue - floor(hue);
      color col = Color.HSBtoRGB(hue, 1.0, 1.0);
      for(int y = 0; y < painter.canvas_height; y++) {
        painter.setPixel(x, y, col);
      }
    }
    this.n_renders++;
    if (this.n_renders > 1) {
      this.reset();
      this.n_renders = 0;
    }
  }
}


public class RotatingRainbow extends PointEffect {
  void render(CanvasPainter painter, Shapes shapes, int frame_num) {
    float angle = (float)Math.PI * 2.0 * (frame_num / 500.0);
    SimpleMatrix xform =
        LinearXforms.rotate(angle)
        .mult(LinearXforms.translate(-painter.canvas_width / 2.0, -painter.canvas_height / 2.0)
        );
        
    for(LedPixel led_pixel: shapes.all_leds) {
      PVector new_pos = LinearXforms.multMatrixByPVector(xform, led_pixel.canvas_position);
      painter.setLedPixel(led_pixel, Color.HSBtoRGB(((int)(frame_num + new_pos.x) & 0xFF) / 255.0, 1.0, 1.0));
    }
  }
}


public class SuperRotatingRainbow1 extends PointEffect {
  void render(CanvasPainter painter, Shapes shapes, int frame_num) {
    float angle = (float)Math.PI * 2.0 * (frame_num / -100.0);
    SimpleMatrix xform =
        LinearXforms.rotate(angle)
        .mult(LinearXforms.translate(-painter.canvas_width / 2.0, -painter.canvas_height / 2.0)
        );
        
    for(LedPixel led_pixel: shapes.all_leds) {
      PVector new_pos = LinearXforms.multMatrixByPVector(xform, led_pixel.canvas_position);
      painter.setLedPixel(led_pixel, Color.HSBtoRGB(((int)(frame_num + new_pos.x) & 0xFF) / 1500.0 + 0.6, 1.0, 1.0));
    }
  }
}


public class SuperRotatingRainbow2 extends PointEffect {
  void render(CanvasPainter painter, Shapes shapes, int frame_num) {
    float angle = (float)Math.PI * 2.0 * (frame_num / 200.0);
    SimpleMatrix xform =
        LinearXforms.rotate(angle)
        .mult(LinearXforms.translate(-painter.canvas_width / 2.0, -painter.canvas_height / 2.0)
        );
        
    for(LedPixel led_pixel: shapes.all_leds) {
      PVector new_pos = LinearXforms.multMatrixByPVector(xform, led_pixel.canvas_position);
      painter.setLedPixel(led_pixel, Color.HSBtoRGB(((int)(frame_num + new_pos.x) & 0xFF) / 1500.0, 1.0, 1.0));
    }
  }
}


/*
 Displays a large dot image on the canvas, centered at the mouse's current location.
*/
public class MouseDot extends CanvasEffect {
  PImage dot;
  
  MouseDot() {
    super();
    dot = loadImage("dot.png");
  }
  
  void render(CanvasPainter painter, Shapes shapes, int frame_num) {
    painter.clearScreen();
    // Draw the image, centered at the mouse location
    float dotSize = painter.canvas_height * 0.7;
    painter.window.image(
      dot,
      painter.window.mouseX - dotSize/2,
      painter.window.mouseY - dotSize/2,
      dotSize,
      dotSize
    );
    painter.loadPixels();
  }  
}


/*
 Multiple "blob" images float around the canvas. Each blob is circular, with a bright center and fades to the edges.
*/
public class BlobEffect extends CanvasEffect {
  PImage dot;
  protected PVector[] ball_coeffs;
  
  BlobEffect() {
    super();
    dot = loadImage("dot.png");
  }

  void reset(Shapes shapes) {
    ball_coeffs = new PVector[16];
    for(int i = 0; i < ball_coeffs.length; i++) {
      ball_coeffs[i] = new PVector(
        (float)(1 / (55 + Math.random() * 50)),
        (float)(1 / (45 + Math.random() * 50)),
        (float)(1 / (85 + Math.random() * 150))
        );
    }
  }
  
  void render(CanvasPainter painter, Shapes shapes, int frame_num) {
    painter.clearScreen();
    float dotSize = painter.canvas_height * 0.7;
    float time = (float)frame_num;
    for(PVector ball_coeff : ball_coeffs) {
      int ball_x = (int)(
          (
            painter.canvas_width + (painter.canvas_width - 2) * Math.sin(time * ball_coeff.x)
          ) * 0.5
      );
      int ball_y = (int)(
          (
            painter.canvas_height + (painter.canvas_height - 2) * Math.cos(time * ball_coeff.y)
          ) * 0.5
      );
      float dot_size = (float)(dot.width * 0.7 * (1.0 + Math.sin(time * ball_coeff.z)) * 0.5);
      painter.window.blend(
        dot, 0, 0, dot.width, dot.height,
        (int)(ball_x - dotSize / 2),
        (int)(ball_y - dotSize / 2),
        (int)dotSize, (int)dotSize,
        SCREEN);
    }
    painter.loadPixels();
  }
}


/*
 Lights up each letter one at a time. When they are all lit, they will flash
 a couple of times, then the cycle restarts.
*/
public class LetterCycleEffect extends PointEffect {
  String[] anim_strings;
  int anim_frame_idx;
  final int INTER_FRAME_DELAY = 15; // Wait this many render() loops before moving onto the next animation frame
  int inter_frame_cnt;
  float hue;

  LetterCycleEffect() {
    // The contents of the string don't matter; the code assumes "<space>" means "letter is off", and anything
    // else means the letter is  on.
    anim_strings = new String[] {
      "      ",
      "O     ",
      "OF    ",
      "OFO   ",
      "OFOS  ",
      "OFOSH ",
      "OFOSHO",
      "OFOSHO",
      "      ",
      "OFOSHO",
      "      ",
      "OFOSHO",
      "      ",
      "OFOSHO",
      "      "
    };
    hue = random(0, 1);
  }

  void reset(Shapes shapes) {
    anim_frame_idx = 0;
    inter_frame_cnt = INTER_FRAME_DELAY;
    hue = random(0, 1);
  }

  void render(CanvasPainter painter, Shapes shapes, int frame_num) {
    int string_idx = 0;
    color letter_col;
    String letters_to_show = anim_strings[anim_frame_idx] + "      ";  // ALways add some padding in case someone didn't make the string at least 6 chars long.
    for (Shape shape: shapes.shapes) {
      char anim_letter;
      try {
        anim_letter = anim_strings[anim_frame_idx].charAt(string_idx++);
      } catch (StringIndexOutOfBoundsException e) {
        anim_letter = ' ';
      }
      if (anim_letter == ' ') {
        letter_col = color(0, 0, 0);  // Space means turns this letter off
      } else {
        letter_col = Color.HSBtoRGB(hue, 1.0, 1.0);
      }
      for (LedPixel led_pixel: shape.leds) {
        painter.setLedPixel(led_pixel, letter_col);
      }
    }

    if (inter_frame_cnt-- <= 0) {
      anim_frame_idx = (anim_frame_idx + 1) % anim_strings.length;
      inter_frame_cnt = INTER_FRAME_DELAY;
    }
  }
}


/*
 Lights up each letter one at a time. When they are all lit, they will flash
 a couple of times, then the cycle restarts.
*/
public class LetterCycleEffect2 extends PointEffect {
  String[] anim_strings;
  int anim_frame_idx;
  final int INTER_FRAME_DELAY = 15; // Wait this many render() loops before moving onto the next animation frame
  int inter_frame_cnt;
  float hue;

  LetterCycleEffect2() {
    // The contents of the string don't matter; the code assumes "<space>" means "letter is off", and anything
    // else means the letter is  on.
    anim_strings = new String[] {
      "      ",
      "O     ",
      "     O",
      " F    ",
      "    H ",
      "  O   ",
      "   S  ",
      "  O H ",
      " F S O",
      "O O H ",
      "      ",
      "OFOSHO",
      "      ",
      "OFOSHO",
      "      ",
      "OFOSHO",
      "      "
    };
    
    hue = random(0, 1);
  }
  
  
  void reset(Shapes shapes) {
    anim_frame_idx = 0;
    inter_frame_cnt = INTER_FRAME_DELAY;
    hue = random(0, 1);
  }

  void render(CanvasPainter painter, Shapes shapes, int frame_num) {
    int string_idx = 0;
    color letter_col;
    String letters_to_show = anim_strings[anim_frame_idx] + "      ";  // ALways add some padding in case someone didn't make the string at least 6 chars long.
    for (Shape shape: shapes.shapes) {
      char anim_letter;
      try {
        anim_letter = anim_strings[anim_frame_idx].charAt(string_idx++);
      } catch (StringIndexOutOfBoundsException e) {
        anim_letter = ' ';
      }
      if (anim_letter == ' ') {
        letter_col = color(0, 0, 0);  // Space means turns this letter off
      } else {
        //letter_col = color(60, 255, 60);  // Anything else means letter is on
        hue = (((hue + 0.04) * 256) % 256)/256;
        letter_col = Color.HSBtoRGB(hue, 1.0, 1.0);
      }
      for (LedPixel led_pixel: shape.leds) {
        painter.setLedPixel(led_pixel, letter_col);
      }
    }

    if (inter_frame_cnt-- <= 0) {
      anim_frame_idx = (anim_frame_idx + 1) % anim_strings.length;
      inter_frame_cnt = INTER_FRAME_DELAY;
    }
    delay(30);
  }
}
