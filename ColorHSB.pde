
// A utility that 
public class ColorHSB {
  int hue;
  int sat;
  int brit;

  int r;
  int g;
  int b;
  
  ColorHSB(int h, int s, int b) {
    hue = h;
    sat = s;
    brit = b;
    // Set the rgb values
    r = round(255 * f(5));
    g = round(255 * f(3));
    b = round(255 * f(1));
  }

  float k(int n) {
    return (n + hue / 60) % 6;
  }
  
  float f(int n) {
    return brit * (1 - sat * max(0, min(k(n), 4 - k(n), 1)));
  }
}
  
