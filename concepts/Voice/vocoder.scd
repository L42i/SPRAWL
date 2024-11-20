s.options.numOutputBusChannels = 12;
s.options.numInputBusChannels = 12;


s.waitForBoot {
    var window, vocoderSlider, reverbSlider, vocoderAmount, reverbAmount, vocoderSynth;
    var sliderWidth = 120;
    var sliderHeight = Window.screenBounds.height - 200;
    var centerX = (Window.screenBounds.width - (2 * sliderWidth + 40)) / 2; // Center both sliders with spacing
    var sliderY = 100;
    window = Window("Vocoder and Reverb Control", Rect(0, 0, Window.screenBounds.width, Window.screenBounds.height));

    // Combined Vocoder and Reverb SynthDef with 6-band output and harmonics
    SynthDef(\vocoderReverbEffect, { |inBus = 0, outBus = 0, vocoderAmount = 0, reverbAmount = 0|
        var input, modulator, vocoder, dryVocoder, wetVocoder, vocoderOutput, reverbOutput;
        var bands, freqs, detune, harmonics;

        // Input from audio input (set to inBus 0 by default)
        input = SoundIn.ar(inBus) * 0.3;  // Reduce input gain if too strong

        // Modulator signal for the vocoder (richer noise and sine wave modulation for a more dynamic effect)
        modulator = Mix.fill(12, { |i| SinOsc.ar(150 + (i * 25)) * 0.15 }) + (WhiteNoise.ar * 0.05);

        // Vocoder processing with smaller buffer size for quicker response
        vocoder = PV_MagMul(FFT(LocalBuf(256), input), FFT(LocalBuf(256), modulator));

        // Blend between dry (unprocessed) and wet (processed) vocoder signals
        dryVocoder = input;
        wetVocoder = IFFT(vocoder);
        vocoderOutput = XFade2.ar(dryVocoder, wetVocoder, vocoderAmount * 2 - 1);

        // Define frequency bands (low to high) with a touch of detuning for richness
		freqs = [100, 200, 300, 400, 450, 500, 750, 1000, 2000, 3000, 4000, 5000];
        detune = [1, 0.995, 1.01, 1.10, 0.48, 1.30, 1, 0.995, 1.01, 1.10, 0.48, 1.30]; // Slight detune factors for each band

        // Apply bandpass filters to split vocoder output into 6 bands, add harmonics, and detune each slightly
        bands = freqs.collect { |freq, i|
            var fundamental = BPF.ar(vocoderOutput * detune[i], freq, 0.15);
            // Add harmonics by mixing in additional sine waves at harmonic intervals
            harmonics = Mix([
                fundamental,
                BPF.ar(vocoderOutput * detune[i], freq * 2, 0.1),   // First harmonic (octave)
                BPF.ar(vocoderOutput * detune[i], freq * 3, 0.1),   // Second harmonic (fifth above octave)
                BPF.ar(vocoderOutput * detune[i], freq * 4, 0.1)    // Third harmonic (two octaves)
            ]);
            harmonics;
        };

        // Add enhanced reverb and stereo widening to each band and route to separate outputs
        bands.do { |band, i|
            var pannedBand = Pan2.ar(band, LFNoise1.kr(0.1).range(-1, 1)); // Slow panning for stereo width
            Out.ar(outBus + i, FreeVerb2.ar(pannedBand, pannedBand, mix: reverbAmount, room: 0.9, damp: 0.5));
        };
    }).add;

    s.sync; // Wait for the server to sync the SynthDefs

    // Create the combined vocoder and reverb synth
    //vocoderSynth = Synth(\vocoderReverbEffect);
	vocoderSynth = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11].collect { |i| Synth(\vocoderReverbEffect,  [\inBus, i])};

    vocoderSlider = Slider(window, Rect(centerX, sliderY, sliderWidth, sliderHeight))
        .orientation_(\vertical) // Set slider orientation to vertical
        .action_({ |sl|
            vocoderAmount = sl.value;
            //vocoderSynth.set(\vocoderAmount, vocoderAmount);
		{ vocoderSynth.do { |synth| synth.set(\vocoderAmount, vocoderAmount); }}
        });

    reverbSlider = Slider(window, Rect(centerX + sliderWidth + 40, sliderY, sliderWidth, sliderHeight))
        .orientation_(\vertical) // Set slider orientation to vertical
        .action_({ |sl|
            reverbAmount = sl.value;
            { vocoderSynth.do { |synth| synth.set(\reverbAmount, reverbAmount); }}
        });

    vocoderSlider.value = 0; // Start at 0% vocoder amount
    reverbSlider.value = 0;  // Start at 0% reverb amount
    window.front;

	s.meter;
};
