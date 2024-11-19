~n_nodes    = 12;
~n_channels = ~n_nodes+1;

s.options.numOutputBusChannels = ~n_channels;
s.options.numInputBusChannels  = ~n_channels;

s.options.memSize = 32*8192;
/*s.boot*/
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

		var in, chain;
		in   = SoundIn.ar(Array.fill(~n_channels,inbus));
		chain = FFT(LocalBuf(16384), in);
		//chain = PV_BrickWall(chain, (((SinOsc.kr(0.1))/2)-0.4));
		//chain = PV_BinScramble(chain, MouseX.kr , 0.1, MouseY.kr > 0.5 );
		//chain = PV_RectComb(chain, 8, LFTri.kr(0.097, 0, 0.4, 0.5), LFTri.kr(0.24, 0, -0.5, 0.5));
		Out.ar(outbus, IFFT(chain)* In.kr(gainbus,~n_channels));
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
		e.setAll(0.08);
		e.setAt(0,1);
	});

	~gain_BUS[0].setAll(2);
	~gain_BUS[0].setAt(0,1);

	OSCdef('/set_time',{ arg msg;
		~mixer.do({arg e; e.set(\time, msg[1])});
		~mixer[0].set(\time, 0);
	},'/set_time');

	OSCdef('/set_network_gain',{ arg msg;

		~gain_BUS.do({arg e,i;
			e.setAll(msg[1]);
		    e.setAt(0,1);
		~gain_BUS[0].setAll(1.5);

	});	},'/set_network_gain');
});