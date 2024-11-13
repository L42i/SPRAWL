~n_nodes = 12;

s.options.numOutputBusChannels = ~n_nodes+1;
s.options.numInputBusChannels = ~n_nodes+1;

//s.options.memSize = 32*8192;

s.waitForBoot({

	~gain_BUS = Array.fill(13,{Bus.control(s,13)});

	s.sync;


	SynthDef(\mesh_mixer,{
		|
		inbus,
		outbus,
		gainbus
		|

		var in   = SoundIn.ar(Array.fill(~n_nodes,inbus));
		var proc = DelayC.ar(in,0.1, Rand.new(0.05,0.1))*0.9;

		Out.ar(outbus, proc* In.kr(gainbus,~n_nodes));

	}).send;

	s.sync;

	~mixer = Array.fill(~n_nodes,{arg i;
		i.postln;
		Synth(\mesh_mixer,[
			\inbus  ,i,
			\outbus ,0,
			\gainbus,~gain_BUS[i]
		]);
	});

	s.meter;


	~gain_BUS.do({arg e,i;
		e.setAll(1);
	});

});