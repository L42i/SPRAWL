s.options.numOutputBusChannels = 2;
s.options.numInputBusChannels = 2;


s.waitForBoot({

// Server Setup


// SynthDefs
SynthDef(\erie,
{
	|pitch = 200, density = 0.2, pd_time = 0.048, q = 0.03, wetDry=0.2, gain=0.707, out=0|
	var s, z, y;
	// 10 voices of a random sine percussion sound :
	s = Mix.ar(Array.fill(10, { Resonz.ar(Dust.ar(density, 55), pitch + 400.0.rand, q)}) );
	// reverb predelay time :
	z = DelayN.ar(s, pd_time);
	// 7 length modulated comb delays in parallel :
	y = Mix.ar(Array.fill(7,{ CombL.ar(z, 0.1, LFNoise1.kr(0.1.rand, 0.04, 0.05), 15) }));
	// two parallel chains of 4 allpass delays (8 total) :
	4.do({ y = AllpassN.ar(y, 0.050, [0.050.rand, 0.050.rand], 1) });
	// add original sound to reverb and play it :
	Out.ar(out, gain * (s + (wetDry*y)));
}
).add;

s.sync;

/*SynthDef(\pulse, {
	arg ampHz=2, fund=40, maxPartial=4, width=0.5, out=0, gain = 0.5;
	var amp1, freq1, sig1;
	amp1 = LFPulse.kr(ampHz, 0, 0.12) * 0.15;
	freq1 = LFNoise0.kr(4).exprange(fund, fund*maxPartial).round(fund);
	freq1 = freq1 * LFPulse.kr(8, add:1);
	sig1 = Pulse.ar(freq1, width, amp1);
	sig1 = FreeVerb.ar(sig1, 0.7, 0.8, 0.25);
	Out.ar(out, gain * sig1);
}
).add;

SynthDef(\R2, {
	arg noiseHz=8;
	var freq, amp, sig;
	freq = LFNoise0.kr(noiseHz).exprange(200,1000);
	amp = LFNoise1.kr(12).exprange(0.02, 1);
	sig = SinOsc.ar(freq) * amp;
	Out.ar(0, sig);
}
).add;*/



// UI
~w = Window.new("GUI Introduction", Rect(
	Window.screenBounds.width/2-200,
	Window.screenBounds.height/2-200,
	800,500));

~synth1 = CompositeView.new(~w,Rect(10,0,250,400));
StaticText.new(~synth1,Rect(60,0,80,20)).string_("Synth 1");
// Generation Controls
StaticText.new(~synth1,Rect(0,30,80,20)).string_("Pitch");
~ctrlFreq = Slider.new(~synth1,Rect(95,30,150,20))
.value_(0.04081633)
.action_{
	arg obj;
	~randomness.set("pitch", obj.value.linexp(0,1,100,5000));
};
StaticText.new(~synth1,Rect(0,60,80,20)).string_("Q factor");
~ctrlQ = Slider.new(~synth1,Rect(95,60,150,20))
.value_(0.003)
.action_{
	arg obj;
	~randomness.set("q", obj.value/4.0);
};
StaticText.new(~synth1,Rect(0,90,100,20)).string_("Density");
~ctrlDensity = Slider.new(~synth1,Rect(95,90,150,20))
.value_(0.2)
.action_{
	arg obj;
	~randomness.set("density", obj.value);
};
// Effects
StaticText.new(~synth1,Rect(0,120,100,20)).string_("Delay Time");
~ctrlPDTime = Slider.new(~synth1,Rect(95,120,150,20))
.value_(0.096)
.action_{
	arg obj;
	~randomness.set("pd_time", obj.value * 2.0);
};
StaticText.new(~synth1,Rect(0,150,100,20)).string_("WetDry");
~ctrlWetDry = Slider.new(~synth1,Rect(95,150,150,20))
.value_(0.2)
.action_{
	arg obj;
	~randomness.set("wetDry", obj.value);
};
StaticText.new(~synth1,Rect(0,180,100,20)).string_("Volume");
~ctrlGain = Slider.new(~synth1,Rect(95,180,150,20))
.value_(0.707)
.action_{
	arg obj;
	~randomness.set("gain", obj.value);
};

// arg ampHz=4, fund=40, maxPartial=4, width=0.5, out=0;
~synth2 = CompositeView.new(~w,Rect(260,0,250,400));
StaticText.new(~synth2,Rect(60,0,80,20)).string_("Synth2");
// Generation Controls
StaticText.new(~synth2,Rect(0,30,80,20)).string_("Pitch");
~ctrlFreq = Slider.new(~synth2,Rect(95,30,150,20))
.value_(0.04081633)
.action_{
	arg obj;
	~randomness2.set("pitch", obj.value.linexp(0,1,100,5000));
};
StaticText.new(~synth2,Rect(0,60,80,20)).string_("Q factor");
~ctrlQ = Slider.new(~synth2,Rect(95,60,150,20))
.value_(0.003)
.action_{
	arg obj;
	~randomness2.set("q", obj.value/4.0);
};
StaticText.new(~synth2,Rect(0,90,100,20)).string_("Density");
~ctrlDensity = Slider.new(~synth2,Rect(95,90,150,20))
.value_(0.2)
.action_{
	arg obj;
	~randomness2.set("density", obj.value);
};
// Effects
StaticText.new(~synth2,Rect(0,120,100,20)).string_("Delay Time");
~ctrlPDTime = Slider.new(~synth2,Rect(95,120,150,20))
.value_(0.096)
.action_{
	arg obj;
	~randomness2.set("pd_time", obj.value * 2.0);
};
StaticText.new(~synth2,Rect(0,150,100,20)).string_("WetDry");
~ctrlWetDry = Slider.new(~synth2,Rect(95,150,150,20))
.value_(0.2)
.action_{
	arg obj;
	~randomness2.set("wetDry", obj.value);
};
StaticText.new(~synth2,Rect(0,180,100,20)).string_("Volume");
~ctrlGain = Slider.new(~synth2,Rect(95,180,150,20))
.value_(0.707)
.action_{
	arg obj;
	~randomness2.set("gain", obj.value);
};


~w.alwaysOnTop_(true);
~w.fullScreen;


// Setup Smart Mesh
// Output synth to 0 and 1

~gain_BUS = Bus.control(s,12);

// SynthCreation
~randomness = Synth("erie",[\out, 0]);
	// ~randomness2 = Synth("erie",[\out, 1]);


});