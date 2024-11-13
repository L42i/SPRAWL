(
s.waitForBoot {

    var window, slider, vocoderAmount, vocoderSynth;

    // GUI
    window = Window("Vocoder Control", Rect(100, 100, 300, 100));

    // Create audio input and vocoder SynthDefs
    SynthDef(\vocoderEffect, { |inBus = 1, outBus = 0, vocoderAmount = 0.5|
        var input, modulator, vocoder, dry, wet;

        // Input from audio input 1
        input = SoundIn.ar(inBus);

        // Modulator signal for the vocoder (e.g., a sine wave or noise)
        modulator = WhiteNoise.ar * EnvGen.kr(Env.perc(0.01, 0.3), Impulse.kr(1));

        // Vocoder processing
        vocoder = PV_MagMul(FFT(LocalBuf(512), input), FFT(LocalBuf(512), modulator));

        // Blend between dry (unprocessed) and wet (processed) signals
        dry = input;
        wet = IFFT(vocoder);
        Out.ar(outBus, XFade2.ar(dry, wet, vocoderAmount * 2 - 1));
    }).add;

    s.sync;  // Wait for the server to sync the SynthDef

    // Create the vocoder synth
    vocoderSynth = Synth(\vocoderEffect);

    // Slider for controlling the vocoder amount
    slider = Slider(window, Rect(20, 20, 260, 20))
        .action_({ |s|
            vocoderAmount = s.value;
            vocoderSynth.set(\vocoderAmount, vocoderAmount);
        });

    // Set initial slider value and open window
    slider.value = 0; // Start at 50% vocoder amount
    window.front;
};
)
