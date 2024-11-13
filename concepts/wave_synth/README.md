Synth Definitions
\inst_input SynthDef: This creates a simple sine wave oscillator that plays at 1000 Hz.
\Wave SynthDef: This defines a more complex synthesizer using white noise filtered by a low-pass filter. The cutoff frequency and amplitude are controlled by envelope generators, which define the shape of these changes over time.
GUI Setup
The GUI allows real-time control over the synthesizer parameters:
Button: Starts a new instance of the \Wave synth with the current slider values.
Sliders: Adjust freq, range, and dur parameters for the synthesizer in real-time.
The sliders are configured to map values for freq (from 400 to 2000), range (from 200 to 600), and dur (from 2.1 to 6.1). Each slider updates the synth parameters as they change, allowing for smooth, live interaction.
