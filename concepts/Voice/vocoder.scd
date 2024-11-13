s.waitForBoot {
    var window, vocoderSlider, reverbSlider, vocoderAmount, reverbAmount, vocoderSynth;
    var sliderWidth = 120;
    var sliderHeight = Window.screenBounds.height - 200;
    var centerX = (Window.screenBounds.width - (2 * sliderWidth + 40)) / 2; // Center both sliders with spacing
    var sliderY = 100;
    window = Window("Vocoder and Reverb Control", Rect(0, 0, Window.screenBounds.width, Window.screenBounds.height));

    // Combined Vocoder and Reverb SynthDef
    SynthDef(\vocoderReverbEffect, { |inBus = 1, outBus = 0, vocoderAmount = 0, reverbAmount = 0|
        var input, modulator, vocoder, dryVocoder, wetVocoder, vocoderOutput, reverbOutput;

        // Input from audio input 1
        input = SoundIn.ar(inBus);

        // Modulator signal for the vocoder (e.g., a sine wave or noise)
        modulator = WhiteNoise.ar * EnvGen.kr(Env.perc(0.01, 0.3), Impulse.kr(1));

        // Vocoder processing
        vocoder = PV_MagMul(FFT(LocalBuf(512), input), FFT(LocalBuf(512), modulator));

        // Blend between dry (unprocessed) and wet (processed) vocoder signals
        dryVocoder = input;
        wetVocoder = IFFT(vocoder);
        vocoderOutput = XFade2.ar(dryVocoder, wetVocoder, vocoderAmount * 2 - 1);

        reverbOutput = FreeVerb.ar(vocoderOutput, mix: reverbAmount);

        // Output reverb to both left and right channels
        Out.ar(outBus, reverbOutput.dup);
    }).add;

    s.sync; // Wait for the server to sync the SynthDefs

    // Create the combined vocoder and reverb synth
    vocoderSynth = Synth(\vocoderReverbEffect);

    vocoderSlider = Slider(window, Rect(centerX, sliderY, sliderWidth, sliderHeight))
        .orientation_(\vertical) // Set slider orientation to vertical
        .action_({ |sl|
            vocoderAmount = sl.value;
            vocoderSynth.set(\vocoderAmount, vocoderAmount);
        });

    reverbSlider = Slider(window, Rect(centerX + sliderWidth + 40, sliderY, sliderWidth, sliderHeight))
        .orientation_(\vertical) // Set slider orientation to vertical
        .action_({ |sl|
            reverbAmount = sl.value;
            vocoderSynth.set(\reverbAmount, reverbAmount);
        });
    vocoderSlider.value = 0; // Start at 0% vocoder amount
    reverbSlider.value = 0;  // Start at 0% reverb amount
    window.front;
};
