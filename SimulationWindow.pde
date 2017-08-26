public class SimWindow extends PApplet {
  boolean window_location_set = false;
  
  public void settings() {
    size(screen_width, screen_height);
  }

  public void setup() {
    background(128);
    fill(64);
  }

  public void draw() {
    if(!window_location_set) {
      surface.setLocation(screen_width, 200);
      window_location_set = true;
    }
    ellipse(100, 50, 10, 10);
  }
}