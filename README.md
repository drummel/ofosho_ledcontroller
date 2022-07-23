# OFOSHO LED Controller

This code generates various LED effects for display on OFOSHO's LED street sign.

It is designed to be run on any Processing platform, including standalone Raspberry Pi without a display.

For instructions on developing this code, see [HACKING](./HACKING.md).

## Running the code

1. Requires [Processing.org](https://processing.org/) 3.x
2. Edit the `FADECANDY_HOST` line in `ofosho_ledcontroller.pde` to specify the IP address of the FadeCandy
   server. It's not necessary to have the FadeCandy server hooked up to run the code.
3. When running this from the Raspberry Pi, you may want to set `IS_SIMULATION_ENABLED` to `false` so that
   the Pi isn't needlessly displaying a window you can't see anyway.

The left window is a canvas where arbitrary effects are rendered, and the LED colors are sampled from it.
This is useful for effects where it's easier to render a large scale canvas first (e.g. a fire effect where
each screen pixel depends on its surrounding pixels). It also overlays the outlines of the OFOSHO letters and
the LED pixels to give you an idea of where the color samples are being picked from.

If the Simulation Window is enabled, a window appears on the right that is meant to simulate what the pixels
look like in reality. (NB: This is based on the old "block" design where the letters were built out of squares,
with each letter fitting in a 3x5 grid). The colors are sampled from the left window, a simple fall-off formula
is applied to simulate the light diffusing through the foam with a hard cut-off at the edges of the plastic.

## User Interface

The effects cycle every 30 seconds, or when you click in the left window. You may notice that sometimes an
effect doesn't appear to change when you click it, but that's because the effect is listed twice in the list,
once as a Canvas Effect and once as a Point Effect. See the Hacking guide for more info.

## LED/letter positions

The `data/shape_description.json` file configures the physical location of the LEDs and letters (referred to
as Shapes). Measurements are in inches. The file supplied with these sketches were all based off estimates
and an old design, so they likely need to be updated.

## Changing the effects

The `ofosho_ledcontroller.pde` file's `setup()` function initializes the list of effects to cycle through.
Comment out or add new effects here.

Most of the Effects are defined in `Effects.pde`.
