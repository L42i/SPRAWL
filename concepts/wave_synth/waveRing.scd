s.waitForBoot

{
SynthDef(\Wave, {
	|out = 0.5, freq = 400, range = 200, dur = 2.1|

	var ampEnv = EnvGen.kr(Env([0, 1, 0], [dur/2, dur/2]), doneAction: Done.freeSelf);
	var freqEnv = EnvGen.kr(Env([freq, freq+range, freq], [dur/2, dur/2], \sin), doneAction: Done.freeSelf);
    Out.ar(0,
		LPF.ar(in: WhiteNoise.ar(out), freq: freqEnv) * ampEnv
    );
}).send(s);

var w = Window("Slider", Rect(128, 64, 1200, 800));

var button = Button(w, Rect(400,50,200,200));

var freqSlider = Slider(w, Rect(10,300,1000,100));
var rangeSlider = Slider(w, Rect(10,500,1000,100));
var durSlider = Slider(w, Rect(10,700,1000,100));

freqSlider.action_({~wave_synth.set(\freq,
	linlin(freqSlider.value.postln, 0, 1, 400, 2000))
});
rangeSlider.action_({~wave_synth.set(\range,
	linlin(rangeSlider.value.postln, 0, 1, 200, 600))
});
durSlider.action_({~wave_synth.set(\dur,
	linlin(durSlider.value.postln, 0, 1, 2.1, 6.1))
});

button.mouseDownAction = {~wave_synth = Synth(\Wave,
	[\out, 0.5, \freq, linlin(freqSlider.value.postln, 0, 1, 400, 2000),
	 \dur, linlin(durSlider.value.postln, 0, 1, 2.1, 6.1),
	 \range, linlin(rangeSlider.value.postln, 0, 1, 200, 600)]
)};

w.front;
};