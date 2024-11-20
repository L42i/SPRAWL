~n_nodes    = 12;
~n_channels = ~n_nodes+1;

s.options.numOutputBusChannels = ~n_channels;
s.options.numInputBusChannels  = ~n_channels;

s.options.memSize = 32*8192;

s.waitForBoot({

	~gain_BUS = Array.fill(~n_channels,{Bus.control(s,~n_channels)});

	s.sync;


	SynthDef(\mesh_mixer,{
		|
		inbus,
		outbus,
		gainbus,
		pitch = 1,
		time = 1
		|

		var in    = SoundIn.ar(Array.fill(~n_channels,inbus));

		var delay   = Lag.kr(time*Rand.new(0.2,0.6),0.1);
		var pitchEr = Lag.kr(max(0.1, 1+(pitch*Rand.new(-0.1,0.1))), 0.1);

		var proc  = PitchShift.ar(DelayC.ar(in,1, max(0,delay)), 0.2, pitchEr);

		Out.ar(outbus, proc* In.kr(gainbus,~n_channels));

	}).send;

	s.sync;

	~mixer = Array.fill(~n_channels,{arg i;
		i.postln;
		Synth(\mesh_mixer,[
			\inbus  ,i,
			\outbus ,0,
			\gainbus,~gain_BUS[i]
		]);
	});

	s.meter;

	~gain_BUS.do({arg e,i;
		e.setAll(0.08);//0.rand(10)/20);
		e.setAt(0,1);
		//~gain_BUS[i].setAt((i+1).wrap(1,~n_nodes),0.2);
	});

	~gain_BUS[0].setAll(2);
	~gain_BUS[0].setAt(0,1);


	OSCdef('/set_pitch',{ arg msg;
		~mixer.do({arg e; e.set(\pitch, msg[1])});
		~mixer[0].set(\pitch, 1);
	},'/set_pitch');


	OSCdef('/set_time',{ arg msg;
		~mixer.do({arg e; e.set(\time, msg[1])});
		~mixer[0].set(\time, 0);
	},'/set_time');


	OSCdef('/set_network_gains',{ arg msg;

		~gain_BUS.do({arg e,i;
			e.setAll(msg[1]);//0.rand(10)/20);
			e.setAt(0,1);
			//~gain_BUS[i].setAt((i+1).wrap(1,~n_nodes),0.2);

			~gain_BUS[0].setAll(msg[1]*1.5);
			~gain_BUS[0].setAt(0,1);});

	},'/set_network_gains');



	OSCdef('/set_network_gain',{ arg msg;

		var idx = msg[1];
		var val = msg[2];

		~gain_BUS[idx+1].setAll(val);

		~gain_BUS[0].setAll(msg[1]*1.5);
		~gain_BUS[0].setAt(0,1);
},'/set_network_gain');

});