Camera : UGen {
	*ar { |input, gain|
		/* TODO */
		^this.multiNew('audio', input, gain);
	}
	*on {
		Server.default.sendMsg(\cmd, \on);
	}
	*off {
		Server.default.sendMsg(\cmd, \off);
	}
	checkInputs {
		/* TODO */
		^this.checkValidInputs;
	}
}
