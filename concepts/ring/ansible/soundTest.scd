s = Server(\quest_test, NetAddr("127.0.0.1", 57111));

// server settings

s.waitForBoot
{

 { Out.ar(0, SinOsc.ar(440, 0, 0.2)) }.play;

};