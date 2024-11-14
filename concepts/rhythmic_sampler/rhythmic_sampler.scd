s.waitForBoot
{
	~folderPath = PathName(thisProcess.nowExecutingPath).parentPath;

	b = Buffer.read (s, ~folderPath +/+ 'samples/kick_4.wav');

	~playRhythmicPattern = { |inputSample, pattern, tempo = 120, rate = 1, loopCount = 1|
		var noteValues, events, delayTimes;

		noteValues = Dictionary[
			"w"   -> 4.0,          // Whole note
			"h"   -> 2.0,          // Half note
			"q"   -> 1.0,          // Quarter note
			"e"   -> 0.5,          // Eighth note
			"s"   -> 0.25,         // Sixteenth note
			"t"   -> 0.125,        // Thirty-second note
			"wt"  -> (4.0 * 2/3),  // Whole triplet
			"ht"  -> (2.0 * 2/3),  // Half triplet
			"qt"  -> (1.0 * 2/3),  // Quarter triplet
			"et"  -> (0.5 * 2/3),  // Eighth triplet
			"st"  -> (0.25 * 2/3), // Sixteenth triplet
			"tt"  -> (0.125 * 2/3),// Thirty-second triplet
			"qr"  -> 1.0,          // Quarter rest
			"hr"  -> 2.0,          // Half rest
			"er"  -> 0.5,          // Eighth rest
			"sr"  -> 0.25,         // Sixteenth rest
			"tr"  -> 0.125,        // Thirty-second rest
			"qtr" -> (1.0 * 2/3),  // Quarter triplet rest
			"etr" -> (0.5 * 2/3),  // Eighth triplet rest
			"str" -> (0.25 * 2/3), // Sixteenth triplet rest
			"ttr" -> (0.125 * 2/3) // Thirty-second triplet rest
		];

		pattern = pattern.replace(" ", "");

		events = pattern.split($,).collect { |note|
			var duration = noteValues[note];
			var isRest = note.endsWith("r");
			if (duration.notNil) {
				(duration: duration, isRest: isRest);
			} {
				(duration: 0, isRest: true); // treat unknown as rest
			}
		};

		delayTimes = events.collect { |event| event[\duration] * (60 / tempo) };

		Routine({
			if (loopCount == inf) {
				loop {
					events.do { |event, i|
						if (event[\isRest].not) {
							Synth(\playSample, [\inputSample, inputSample, \rate, rate, \gate, 1]);
						};
						(delayTimes[i]).wait;
					};
				};
			} {
				loopCount.do {
					events.do { |event, i|
						if (event[\isRest].not) {
							Synth(\playSample, [\inputSample, inputSample, \rate, rate, \gate, 1]);
						};
						(delayTimes[i]).wait;
					};
				};
			};
		}).play;
	};

	SynthDef(\playSample, {
		arg inputSample, rate = 1, gate = 1;
		var sound;

		sound = PlayBuf.ar(2, inputSample, BufRateScale.kr(inputSample) * rate, doneAction: Done.freeSelf);
		sound = sound * EnvGen.kr(Env.asr(0.01, 1, 0.1), gate, doneAction: Done.freeSelf);

		Out.ar(0, sound);
	}).add;

	// Run this to play the function
	~g1 = Routine({~playRhythmicPattern.(b, "e,e, qr, e,e, qr", 100, 5, 64)});
	~g2 = Routine({~playRhythmicPattern.(b, "qr, q, qr, q", 100, 5, 32)});

	~g1.play;
	~g2.play;
};