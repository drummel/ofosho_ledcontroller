/**
 * This is the "main" file.
 */

// Set this to false to disable opening the Simulation window. This window is not
// necessary when running on the Raspberry Pi, it just consumes more CPU.
final boolean SIMULATION_ENABLED = true;
final String FADECANDY_HOST = "127.0.0.1";
final int FADECANDY_PORT = 7890;
final int CANVAS_WIDTH = 640;
final int CANVAS_HEIGHT = 200;

boolean window_location_set = false;
EffectController effect_controller;

void settings() {
  size(CANVAS_WIDTH, CANVAS_HEIGHT);
}

void setup()
{
  // This is commented out as it's not normally supposed to be run. We add it in here just for convenience because
  // Processing makes it harder to make multiple application entry points. If it's uncommented, it just generates
  // a basic shapes_description.json file and exits immediately.
  // genShapeFile();
  
  effect_controller = new EffectController(this);
}

void draw()
{
  if(!window_location_set) {
    // For technical reasons this code needs to be in draw(), not setup().
    surface.setLocation(0,200);
    window_location_set = true;
  }

  effect_controller.renderEffects();
}