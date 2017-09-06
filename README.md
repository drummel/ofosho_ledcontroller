# OFOSHO LED Controller

This code generates various LED effects for display on OFOSHO's LED street sign.

It is designed to be run on any Processing platform, including standalone Raspberry Pi without a display.

The OFOSHO LED sign is comprised of various strips of NeoPixels, run by a FadeCandy controller:

  Processing.org running this application [running on PC or Raspberry Pi]
    [connects over TCP to]
  FadeCandy Server [running on Raspberry Pi]
    [connects via USB to]
  FadeCandy board
    [connects physically to]
  NeoPixel LED strips

## Windows

The left window is a canvas where arbitrary effects are rendered, and the LED colors are sampled from it. This is useful for effects where it's easier to render a large scale canvas first (e.g. a fire effect where each screen pixel depends on its surrounding pixels). It also overlays the outlines of the OFOSHO letters and the LED pixels to give you an idea of where the color samples are being picked from.

The right window is a simulation of what the pixels will look like in real life. I just sample the colors from the left window, and apply a simple fall-off formula to simulate the light diffusing through the foam with a hard cut-off at the edges of the plastic.

## User Interface

The effects cycle every 30 seconds, or when you click in the left window. You may notice that sometimes an effect doesn't appear to change when you click it, but that's because the effect is listed twice in the list, once as a Canvas Effect and once as a Point Effect (see below).

## LED/letter positions

I knew the dimensions of the plastic but I didn't know the exact locations of the LEDs within the plastic so I guessed. (Slightly incorrectly, as it turned out). There's a function (which isn't run during normal operation) that generates the positions of the LEDs and the positions/rotations of the plastic letters, and writes them to a JSON file so they can be tweaked manually, and then the program (during normal operation) reads in the JSON file. I'll have to examine the physical LEDs to make this code more accurate.

## Effect types

There are 2 effect types: Canvas and Point effect.

Canvas effects involve rendering an entire canvas (e.g plasma, fire) and then point sampling the canvas to get the LED color values. Because they involve calculating a color for each pixel in the canvas, they are computationally expensive (for a Pi) but it's easier to see what's going on.

Point effects calculate the LED colors directly (e.g. chasing LED effects). These are much cheaper since there's only 1 calculation per LED. Some effects (e.g. plasma & fire) are implemented as both Canvas Effects and Point Effects. I first implemented them as Canvas Effects because it was easier to see what was going on, then re-implemented them as Point Effects so they could be run more cheaply.

The list of all effects is at the top of Effects.pde, although the code for each effect is kinda spread around a bit.