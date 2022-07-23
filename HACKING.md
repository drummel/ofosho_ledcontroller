# Hacking

This section explains how the code and hardware work, and how to modify the software.


## Hardware setup

The OFOSHO LED sign is comprised of 6 NeoPixel strips (one for each letter), run by a FadeCandy controller:

  Processing.org running this application [running on PC or Raspberry Pi]
    [connects over TCP to]
  FadeCandy Server [running on Raspberry Pi]
    [connects via USB to]
  FadeCandy board
    [connects physically to]
  NeoPixel LED strips


## Software architecture


### What the software does

The software animates LED lighting in the OFOSHO camp sign. It defines various animation styles called "effects" (e.g. smoothly changing colors,
LEDs "chasing" each other, etc). The program cycles through each effect every 30 seconds (or when the mouse is clicked). The code is designed
to make it easy to add new effects.

An optional "Simulation Window" can be enabled to support development when the physical LEDs are not available. This displays a separate
window that crudely approximates how the LEDs will look like in reality: it attempts to show the LEDs arranged as they would be in their boxes,
behind diffuse white plastic, surrounded by an opaque material that outlines the letters. (NB: the current simulation code assume the letters
and LEDs are arranged differently than they are today, so this needs to be updated)


### How the code works

The program assigns each LED a static X/Y coordinate on Processing's default canvas, that should roughly be positioned relative to where that
LED is located within the OFOSHO sign. Each animation cycle, the program draws colors to the canvas. After the canvas is painted, the canvas is
sampled to retrieve the color at each LED's location, and the LED/color info is sent to the FadeCandy server.

If the Simulation is enabled, the LEDs colors are used to animate a separate window that attempts to show what the LEDs look like in reality.


### Code structure

The code can be broken down into various components. Each will be covered in detail in following sections.
- Initialization and configuration. This includes reading a JSON file from disc that describes each of the letter shapes.
- The standard Processing.org `setup()` and `draw()` functions. Processing runs the `draw()` function every animation cycle, whicn in turn
  runs the `EffectsController` that decides what effect to draw on the canvas.
- A variety of Effects implementations that draw animations to the canvas.
- The `OPC` thread reads the canvas and sends the LED/color data to the FadeCandy server.
- The optional `SimulationWindow`.

The code's important data structures:
- `LedPixel`: represents a specific NeoPixel; its color, position in the physical world, and position on the virtual canvas.
- `Shape`: represents one of the OFOSHO letters; its position in the physical world, and the LEDs inside it.
- `Shapes`: Contains all the 6 shapes.


### `draw()` loop and `EffectsController`

The `EffectsController` is the "manager" that directs the drawing process. It decides which effect should be drawn, and cycles to the next
effect after a delay.

Processing supplies a default canvas, and it calls a `draw()` method every animation frame. This in turn calls the `EffectsController`'s
`renderEffects()` method that is the "main loop".

On each animation cycle, it sets up the canvas, tells a specific effect to render a canvas frame, and overlays a faint image of what the
diffuse plastic would look like. (NB: This plastic image is out of date with the current box design).

Each LED's location is also marked by a dot on the canvas. (This dot is actually added by the OPC thread.)


### Effects

Each effect implements the `IEffect` interface, which is pretty simple. `reset()` is called whenever the `EffectController` changes to this
effect. `render()` is called by the `EffectController` every animation cycle to draw on the canvas.

There are 2 ways of writing an `Effect`:

A **Canvas** Effect is where the algorithm finds it easier to render the entire canvas. The LED colors are sampled from their assigned
locations within the canvas. The upside of this approach is that sometimes the algorithm is easier to follow. However it's likely to
compute values for pixels that are not mapped to an LED, so it's computationally wasteful.

A **Point** Effect is where the algorithm computes the colors of each LED directly. It doesn't need to bother covering the whole canvas.
This is more computationally efficient, but sometimes the algorithm can be harder to follow, and it's also harder to see what the
final effect will look like without the Simulator.


### Open Pixel Control (OPC)

This is a 3rd-party piece of code that handles sending the LED colors to the FadeCandy. It runs in a separate Thread, and sets itself
up to be automatically executed at the end of the main `draw()` loop. The main program initializes it with the IP/port of the FadeCandy
server, and registers the location of each of the LEDs within the main canvas. This thread will automatically read the colors from those
locations, bundle them and send them to FadeCandy.

It's designed to be resilient; if it can't connect to the FadeCandy server, it will continually retry.


### PlasticMask

The `PlasticMask` is used by the `EffectController` and the Simulator to generate a couple of images in the shape of the sign. These
are blended with the canvases to give an idea of how the LEDs will look in reality. One mask is used to faintly show the diffuse
plastic, and its inverse is used to set all pixels outside the box to black.


### Simulation

This is a separate `PApplet` that runs its own window and `draw()` loop. It looks at the LED colors and attempts to draw a crude
representation of what the LEDs will look like. NB: This simulator was based on an old version of the physical lights where each
letter was constructed out of boxes. The simulator is mostly irrelevant now since the box design has changed.


## Shape configuration

Each letter in "OFOSHO" is represented as a `Shape` object which describes the physical position of its containing box, and the
physical location of the LEDs inside it. This data is stored in a JSON file `data/shape_description.json`.

Entering this data by hand is quite tedious, so the `ShapeFileGenerator.pde` code is a quick-and-dirty way of generating that
data (according to the old outdated design). Rather than have the generator code in a complete separate sketch, it's run by
manually uncommenting a line in the main `ofosho_ledcontroller.pde` file and running the main program, which will then
run the generator, save the sample JSON file, and exit.

The `world_x` / `world_y` coordinates are measured in inches, and are relative to whatever origin you like; when they're read in,
the program will normalize and center them to its own coordinate system.
