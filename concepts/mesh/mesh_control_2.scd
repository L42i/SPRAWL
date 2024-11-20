~addresses = [
"10.10.10.101",
"10.10.10.102",
"10.10.10.103",
"10.10.10.104",
"10.10.10.105",
"10.10.10.106",
"10.10.10.107",
"10.10.10.108",
"10.10.10.109",
"10.10.10.110",
"10.10.10.111",
"10.10.10.112"];


~aps = Array.fill(12,{arg i;
	NetAddr.new(~addresses[i], 57120);
});

/*

~aps.do({arg e,i; e.sendMsg(\set_network_gain,0)});
~aps.do({arg e,i; e.sendMsg(\set_network_gain,0.08)});

~aps.do({arg e,i; e.sendMsg(\set_pitch,2)});
~aps.do({arg e,i; e.sendMsg(\set_pitch,1)});
~aps.do({arg e,i; e.sendMsg(\set_pitch,0)});

~aps.do({arg e,i; e.sendMsg(\set_time,0)});
~aps.do({arg e,i; e.sendMsg(\set_time,1)});
~aps.do({arg e,i; e.sendMsg(\set_time,2)});

*/


~window = Window("Mesh Remote",Rect(100,100,1800,900));
~window.front;

~slider_1 = Slider(~window,Rect(10,10,100,800));



~xy_1 = Slider2D(~window,Rect(10,10,800,800));
~xy_1.action_({|sl|

	var shift  = sl.x * 2;
	var gain  = sl.y * 1;


	var x = (1+sl.x) * sl.y*abs((0..11)/12).pow(8*sl.x + 1);

	~aps.do({arg e,i;
		var y = x.rotate(i);
		y.plot;
		//y.postln;
		y.do({arg element, index; e.sendMsg(\set_network_gain, element);});
	});

});


~xy_2 = Slider2D(~window,Rect(900,10,800,800));
~xy_2.action_({|sl|

	var time  = sl.x * 2;
	var pitch = (sl.y-0.5) * 4;

	~aps.do({arg e,i; e.sendMsg(\set_pitch,pitch)});
	~aps.do({arg e,i; e.sendMsg(\set_time,time)});

});
