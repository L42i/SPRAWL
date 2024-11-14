s.boot;

(
{
    var in, chain;
    in = SoundIn.ar(0, 10.0, 0);
    chain = FFT(LocalBuf(16384), in);
	chain = PV_BrickWall(chain, (((SinOsc.kr(0.1))/2)-0.4));
	chain = PV_BinScramble(chain, MouseX.kr , 0.1, MouseY.kr > 0.5 );
	chain = PV_RectComb(chain, 8, LFTri.kr(0.097, 0, 0.4, 0.5),
    LFTri.kr(0.24, 0, -0.5, 0.5));
	IFFT(chain);
}.play
)