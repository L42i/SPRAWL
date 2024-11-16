Camera : UGen {
	*ar { |input, gain|
		/* TODO */
		^this.multiNew('audio', input, gain);
	}
	*on {
		Server.default.sendMsg(\cmd, \on);
	}
	checkInputs {
		/* TODO */
		^this.checkValidInputs;
	}
}
