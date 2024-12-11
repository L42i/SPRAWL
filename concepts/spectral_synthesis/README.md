# Duncan and Evan

## Notes:
- This folder contains the script to run on a Raspberry Pi connected to speakers, `spectralfx.scd`.
    - This plugin is designed to spectrally morph incoming audio by leveraging several classes from the FFT library. Parameters are mapped to the mouse's X and Y coordinates and LFOs.
- The `supercollidercamera/` folder contains a SuperCollider server plugin which can control synths with camera input
    - This particular plugin is designed to track people and map the center coordinates of the detected person to a synth. The spectralfx synth running on the Raspberry Pi described above will be the synth which this control input is mapped to.

## Spectral FX
The `spectralfx.scd` script should be installed and run on each Pi. Incoming signal is converted to frequency data with an FFT. Smaller bin sizes cause less latency, but more of a digital sound, whereas larger bin sizes cause more latency, but more of a blurred sound with pre-ring. Larger bin sizes are recommended due to the high latency causing more interesting delays and audio output. PV_Brickwall works as a low and hi-pass filter, with the cutoff controlled by a sine-shaped LFO. PV_BinScramble then randomizes the order of the bins, with the amount of bins being scrambled and the re-triggering being controlled by the X and Y mouse coordinates. Lastly, PV_RectComb was used as a spectral comb filter to cut off different frequencies. The phase and pulse width of the comb were modulated by two triangle-shaped LFOs. The IFFT turns the frequency information back into a signal, which is sent to the mesh mixer.

## SuperCollider Camera
Everything in the `supercollidercamera/` folder should be installed on a personal machine. It was made clear the package dependencies of the Raspberry Pi are not to be messed with, thus requiring the plugin to run on a personal computer since it requires the `libopencv-dev` package to be installed. This package could install other dependencies on the Raspberry Pi which was not desired. The machine used for this specific performance is a MacBook Pro with a camera running its own SuperCollider server. That way, commands can be sent from the MacBook SuperCollider server to the Raspberry Pi SuperCollider server, assuming both are connected to the same Local Area Network (LAN).

To install, run the following commands:

```
sudo apt install libopencv-dev
cd supercollidercamera
mkdir build && cd build
cmake-gui ..
```

Once the window shows up, make sure the options look like the options below except with your username instead of `evan`.

![Cmake Window](doc/CmakeWindow.png)

Then run the following commands:

```
make -j`nproc`
make install
```
