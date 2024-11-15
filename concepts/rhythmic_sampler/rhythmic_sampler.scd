s.waitForBoot
{
	// Read in a sample
	~folderPath = PathName(thisProcess.nowExecutingPath).parentPath;
	b = Buffer.read (s, ~folderPath +/+ 'samples/kick_4.wav');

	//Initialize GUI variables
	w;
	~b1;
	~b2;
	~ttb;

	// Load a default pattern
	~pattern = "wr";

	// Initialize a dictionary for converting characters to and from duration values
	~noteValues = Dictionary[
		"w" -> 4.0,   "4.0" -> 4.0,           // Whole note
		"3.75" -> 3.75,
		"3.5" -> 3.5,
		"3.25" -> 3.25,
		"3.0" -> 3.0,
		"2.75" -> 2.75,
		"2.5" -> 2.5,
		"2.25" -> 2.25,
		"h" -> 2.0,   "2.0" -> 2.0,           // Half note
		"1.75" -> 1.75,
		"1.5" -> 1.5,
		"1.25" -> 1.25,
		"q" -> 1.0,   "1.0" -> 1.0,           // Quarter note
		"0.75" -> 0.75,
		"e" -> 0.5,   "0.5" -> 0.5,           // Eighth note
		"s" -> 0.25,  "0.25" -> 0.25,         // Sixteenth note
		"t" -> 0.125, "0.125" -> 0.125,                   // Thirty-second note
		"wt" -> (4.0 * 2/3), (4.0 * 2/3) -> (4.0 * 2/3),  // Whole triplet
		"ht" -> (2.0 * 2/3), (2.0 * 2/3) -> (2.0 * 2/3),  // Half triplet
		"qt" -> (1.0 * 2/3), (1.0 * 2/3) -> (1.0 * 2/3),  // Quarter triplet
		"et" -> (0.5 * 2/3), (0.5 * 2/3) -> (0.5 * 2/3),  // Eighth triplet
		"st" -> (0.25 * 2/3), (0.25 * 2/3) -> (0.25 * 2/3), // Sixteenth triplet
		"tt" -> (0.125 * 2/3), (0.125 * 2/3) -> (0.125 * 2/3), // Thirty-second triplet
		"qr" -> 1.0, "1.0r" -> 1.0,           // Quarter rest
		"hr" -> 2.0, "2.0r" -> 2.0,           // Half rest
		"er" -> 0.5, "0.5r" -> 0.5,           // Eighth rest
		"sr" -> 0.25, "0.25r" -> 0.25,        // Sixteenth rest
		"tr" -> 0.125, "0.125r" -> 0.125,     // Thirty-second rest
		"qtr" -> (1.0 * 2/3), (1.0 * 2/3) -> (1.0 * 2/3),  // Quarter triplet rest
		"etr" -> (0.5 * 2/3), (0.5 * 2/3) -> (0.5 * 2/3),  // Eighth triplet rest
		"str" -> (0.25 * 2/3), (0.25 * 2/3) -> (0.25 * 2/3), // Sixteenth triplet rest
		"ttr" -> (0.125 * 2/3), (0.125 * 2/3) -> (0.125 * 2/3) // Thirty-second triplet rest
	];

	// This function takes the rhythmic pattern and plays it with the loaded sample
	~playRhythmicPattern = { |inputSample, pattern, tempo = 120, rate = 1, loopCount = 1|
		var events, delayTimes;

		// Pre-process the pattern string
		pattern = pattern.replace(" ", "");

		events = pattern.split($,).collect { |note|
			var duration = ~noteValues[note];
			var isRest = note.endsWith("r");
			if (duration.notNil) {
				(duration: duration, isRest: isRest);
			} {
				(duration: 0, isRest: true); // treat unknown as rest
			}
		};

		delayTimes = events.collect { |event| event[\duration] * (60 / tempo) };

		// Create a routine
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

	// This function takes the data from the checkboxes and converts them into a string containing a rhythmic pattern
	~parsePattern = {
		var tempcount = 0;
		var temp_pattern = "";
		var numofnotes = 0;

		// Loop through each button
		~tba.do({ |cb, i|
			if (cb.value == 1, { // If the current checkbox is checked...
				if (temp_pattern == "", { // If the pattern does not have any data in it yet...
					if (i == 0, { // If this is the first checkbox...
						tempcount = tempcount + 0.25;
					}, { // If this is not the first checkbox...
						if (numofnotes == 0, { // If no checked checkboxes have been found yet...
							temp_pattern = temp_pattern ++ tempcount ++ "r";
						}, {
							temp_pattern = temp_pattern ++ tempcount;
						});

						tempcount = 0.25;
					});
				}, { // If we already have data in the pattern...
					temp_pattern = temp_pattern ++ ", " ++ tempcount;
					tempcount = 0.25;
				});

				numofnotes = numofnotes + 1;
			}, { // If the current checkbox is unchecked...
				if (temp_pattern == "", { // If the pattern does not have any data in it yet...
					if (i == 0, { // If this is the first checkbox...
						tempcount = tempcount + 0.25;
					}, { // If this is not the first checkbox...
						tempcount = tempcount + 0.25;
					});
				}, { // If we already have data in the pattern...
					tempcount = tempcount + 0.25;
				});
			});
		});

		if (temp_pattern == "", { // If the pattern has no data in it...
			if (numofnotes > 0, { // If there have been checks found, add the last note to the pattern
				temp_pattern = temp_pattern ++ tempcount;
			}, { // If there are no boxes checked, the pattern must be a whole note rest
				temp_pattern = temp_pattern ++ tempcount ++ "r"
			});
		}, { // If the pattern has data in it, add the last note to the pattern
			temp_pattern = temp_pattern ++ ", " ++ tempcount;
		});

		// Rewrite the main pattern
		~pattern = temp_pattern;
	};

	SynthDef(\playSample, {
		arg inputSample, rate = 1, gate = 1;
		var sound;

		sound = PlayBuf.ar(2, inputSample, BufRateScale.kr(inputSample) * rate, doneAction: Done.freeSelf);
		sound = sound * EnvGen.kr(Env.asr(0.01, 1, 0.1), gate, doneAction: Done.freeSelf);

		Out.ar(0, sound);
	}).add;

	// Run this to play the function
	~g1 = Routine({~playRhythmicPattern.(b, ~pattern, 100, 5, 64)});

	// Make the GUI
	w = Window("Rhythmic Sampler", Rect(128, 64, 800, 480));

	// Make a play and stop button
	~b1 = Button(w, Rect(100, 50, 150, 150))
	.states_([["Play"]])
	.action_({ ~g1.play });

	~b2 = Button(w, Rect(350, 50, 150, 150))
	.states_([["Stop"]])
	.action_({ ~g1.stop });

	// Create array of buttons to represent the rhythmic pattern
	~tba = 16.collect({
		arg n;

		b = Button(w, Rect(100 + (n * 60), 300, 60, 60))
        .states_([
            ["", Color.grey, Color.white],
            ["X", Color.white, Color.grey]
        ])
        .action_({ arg butt;
            ~parsePattern.();
		});
});

	// Show the GUI and make it full screen!
	w.fullScreen;
	w.front;
};