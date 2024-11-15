p = ServerOptions.new;

p.memSize = 4096;

// set a different port to let this  server run next to*/

t = Server(\lights, NetAddr("127.0.0.1", 57111), p);

// server settings
t.options.device               = "lights";
//t.options.sampleRate = 48000;

t.boot;

t.waitForBoot{
        "hi".postln;

        ~port = SerialPort("/dev/ttyACM0", 115200);  // Use the correct port for your setup
        // ~port = SerialPort("/dev/cu.usbmodem14201", 115200);

        ~isReady = false;

        if (~port.isNil.not && ~port.isOpen) {
                "Serial port is open and ready.".postln;
                ~isReady = true;
        } {
                "Error: Serial port could not be opened.".error;
        };


        if(~isReady) {

                "nice!".postln;

                ~input = {

                        var in, amp;
                        in = SoundIn.ar(0); // Input from audio interface channel 1
                        amp = Amplitude.kr(in);
                        amp = (amp * 255).clip(0, 255); // Scale amplitude to 0-255
                        SendReply.kr(Impulse.kr(20), '/amp', amp); // Send data 20 times per second
                        Silent.ar(1); // No audio output needed
                }.play(t);


                OSCdef(\receiveAmp, { |msg|
                        var amp, intAmp;
                        // Extract the amplitude value from the OSC message
                        amp = msg[3];
                        intAmp = amp.round(1).asInteger; // Round and convert to integer

                        // Debug: Print the received amplitude
                        // ("Received amplitude: " ++ intAmp).postln;

                        // Check if port is open and send amplitude over serial
                        if (~port.notNil and: ~port.isOpen) {
                                ~port.put(intAmp); // Send as a single byte
                        } {
                                "Serial port is not open.".warn;
                        }
                }, '/amp');

        }

};