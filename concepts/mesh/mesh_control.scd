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



~aps.do({arg e,i; e.sendMsg(\set_network_gain,0)});
~aps.do({arg e,i; e.sendMsg(\set_network_gain,0.08)});

~aps.do({arg e,i; e.sendMsg(\set_pitch,2)});
~aps.do({arg e,i; e.sendMsg(\set_pitch,1)});
~aps.do({arg e,i; e.sendMsg(\set_pitch,0)});

~aps.do({arg e,i; e.sendMsg(\set_time,0)});
~aps.do({arg e,i; e.sendMsg(\set_time,1)});
~aps.do({arg e,i; e.sendMsg(\set_time,2)});


