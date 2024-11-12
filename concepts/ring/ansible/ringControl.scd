s.waitForBoot
{



var x = { | gain=0.9, delay=0.5| var input = SoundIn.ar(0);

        var processed = DelayC.ar(input, 2, delay, gain);
        Out.ar(0, processed);
}.play;

var w = Window("Slider",Rect(128,64,800,480));

var slider = Slider2D(w, Rect(10,10,555,555));

slider.action_({|sl|
        x.set(\gain,sl.y);
        x.set(\delay, sl.x);

});

w.fullScreen;
//w.front;
};