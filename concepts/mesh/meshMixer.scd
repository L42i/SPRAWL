~n_nodes = 12;
 
s.options.numOutputBusChannels = ~n_nodes;
s.options.numInputBusChannels = ~n_nodes;
 
s.waitForBoot({
 
	~gain_BUS = Array.fill(12,{Bus.control(s,12)});
 
	SynthDef(\mesh_mixer,{
		|
		inbus,
		outbus,
		gainbus
		|
		Out.ar(outbus, SoundIn.ar(Array.fill(~n_nodes,inbus)) * In.kr(gainbus,~n_nodes));
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
 
 
});