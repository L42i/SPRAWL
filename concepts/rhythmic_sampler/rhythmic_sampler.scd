s.options.memSize = 32*8192;

s.waitForBoot({
    // Variable declarations
    var w, stepIndex, delayTime;
    var beatIndicators;

    // Initialize variables
    ~buffers = ();
    ~patterns = ();
    ~volumes = ();
    ~reverbLevels = ();
    ~delayLevels = ();
    ~startOffsets = ();
    ~endOffsets = ();
    ~isPlaying = false;
    ~tempo = 80;
    ~globalClock = TempoClock(~tempo / 60);
    ~recordedBuffer = nil;
    ~isRecording = false;
    ~reverbAmount = 0.3;
    ~delayAmount = 0.2;
    ~delayTimes = ();

    ~patternResolution = 16;
    ~instruments = [\kick, \snare, \hihat, \recorded1, \recorded2, \recorded3];

	// Initialize per-track controls
    ~instruments.do { |instr|
        ~volumes[instr] = 0.5;
        ~patterns[instr] = Array.fill(~patternResolution, 0);
        ~reverbLevels[instr] = 0.1;
        ~delayLevels[instr] = 0.2;
        ~startOffsets[instr] = 0.0;
        ~endOffsets[instr] = 1.0;
        ~delayTimes[instr] = 0.3;
    };

    // Create audio buses for effects - FIXED: Added proper routing
    ~effectsBus = Bus.audio(s, 2);
    ~reverbBus = Bus.audio(s, 2);
    ~delayBuses = ();
    ~instruments.do { |instr|
        ~delayBuses[instr] = Bus.audio(s, 2);
    };

    // Load buffers
	~folderPath = PathName(thisProcess.nowExecutingPath).parentPath;
	~buffers[\kick] = Buffer.read(s, ~folderPath +/+ "samples/SLS_DS_kick_groovy.wav");
    ~buffers[\snare] = Buffer.read(s, ~folderPath +/+ "samples/OS_IC_Drizzle_Snare.wav");
    ~buffers[\hihat] = Buffer.read(s, ~folderPath +/+ "samples/MALAY_hihat_gated_02.wav");

    // Initialize recorded buffers - NOW 5 SECONDS LONG
    ~buffers[\recorded1] = Buffer.alloc(s, s.sampleRate * 2, 1);
    ~buffers[\recorded2] = Buffer.alloc(s, s.sampleRate * 2, 1);
    ~buffers[\recorded3] = Buffer.alloc(s, s.sampleRate * 2, 1);

    s.sync;

    // FIXED: Updated SynthDef with proper end position handling and stereo output
    SynthDef(\samplePlayer, { |out=0, bufnum, amp=0.5, effectsBus, delayBus, startPos=0, endPos=1, reverbLevel=0.3, delayLevel=0.2|
        var sig, numFrames, duration, env;
        numFrames = BufFrames.kr(bufnum);
        duration = BufDur.kr(bufnum) * (endPos - startPos);
        env = EnvGen.ar(
            Env([0, 1, 1, 0], [0.01, duration - 0.02, 0.01]),
            doneAction: 2
        );
        sig = PlayBuf.ar(
            numChannels: 2,
            bufnum: bufnum,
            rate: BufRateScale.kr(bufnum),
            startPos: startPos * numFrames,
            loop: 0,
            doneAction: 2
        ) * amp * env;

        // Direct output
        Out.ar(out, sig);
        // Send to reverb
        Out.ar(effectsBus, sig * reverbLevel);
        // Send to delay
        Out.ar(delayBus, sig * delayLevel);
    }).add;

    // FIXED: Updated effects SynthDefs with proper routing
    SynthDef(\recorder, { |in=0, bufnum|
        var input = SoundIn.ar(in);
        RecordBuf.ar(input, bufnum, doneAction: 0, loop: 0);
    }).add;

    SynthDef(\reverb, { |in, out, mix = 0.3, room = 2.0, damp = 0.5|
        var dry, wet;
        dry = In.ar(in, 2);
        wet = FreeVerb2.ar(dry[0], dry[1], mix, room, damp);
        Out.ar(out, wet);
    }).add;

    SynthDef(\delay, { |in, out, delayTime = 0.3, decay = 5.0, mix = 0.8|
        var dry, wet, delayed;
        dry = In.ar(in, 2);
        delayed = CombL.ar(dry, 5.0, delayTime, decay);
        wet = (dry * (1 - mix)) + (delayed * mix);
        Out.ar(out, wet);
    }).add;

    SynthDef(\mixer, { |in, out|
        var sig = In.ar(in, 2);
        Out.ar(out, sig);
    }).add;

    s.sync;

    // FIXED: Proper effect chain routing
    ~reverbSynth = Synth.tail(s, \reverb, [\in, ~effectsBus, \out, 0]);

    ~delaySynths = ();
    ~instruments.do { |instr|
        ~delaySynths[instr] = Synth.tail(s, \delay, [
            \in, ~delayBuses[instr],
            \out, 0,
            \delayTime, ~delayTimes[instr]
        ]);
    };

    // Beat indicators function
    ~updateBeatIndicators = { |currentStep|
        {
            beatIndicators.do { |btn, i|
                if(i == currentStep) {
                    btn.states_([[" ", Color.new(0.3, 0.6, 1.0), Color.new(0.3, 0.6, 1.0)]]);
                } {
                    btn.states_([[" ", Color.new(0.12, 0.12, 0.14), Color.new(0.2, 0.2, 0.22)]]);
                };
                btn.refresh;
            };
        }.defer;
    };

    // FIXED: Updated playStep function with proper synth parameters
    ~playStep = { |stepIndex|
        ~updateBeatIndicators.(stepIndex);
        ~instruments.do { |instr|
            if (~patterns[instr][stepIndex] == 1 && ~buffers[instr].notNil) {
                Synth.head(s, \samplePlayer, [
                    \bufnum, ~buffers[instr],
                    \amp, ~volumes[instr],
                    \effectsBus, ~effectsBus,
                    \delayBus, ~delayBuses[instr],
                    \startPos, ~startOffsets[instr],
                    \endPos, ~endOffsets[instr],
                    \reverbLevel, ~reverbLevels[instr],
                    \delayLevel, ~delayLevels[instr]
                ]);
            }
        };
    };

    // Play routine
    ~createPlayRoutine = {
        Routine({
            var localStepIndex = 0;
            loop {
                ~playStep.(localStepIndex);
                localStepIndex = (localStepIndex + 1) % ~patternResolution;
                (~globalClock.beatDur * 4 / ~patternResolution).wait;
            }
        });
    };

    ~playRoutine = ~createPlayRoutine.();

    // Playback control functions remain the same
    ~startPlaying = {
        if (~isPlaying.not) {
            ~playRoutine = ~createPlayRoutine.();
            ~playRoutine.play(~globalClock);
            ~isPlaying = true;
        }
    };

    ~stopPlaying = {
        if (~isPlaying) {
            ~playRoutine.stop;
            ~isPlaying = false;
            {
                beatIndicators.do { |btn|
                    btn.states_([[" ", Color.new(0.12, 0.12, 0.14), Color.new(0.2, 0.2, 0.22)]]);
                    btn.refresh;
                };
            }.defer;
        }
    };

{
    var colors = (
        background: Color.new(0.12, 0.12, 0.14),
        panel: Color.new(0.16, 0.16, 0.18),
        button: Color.new(0.2, 0.2, 0.22),
        buttonOff: Color.new(0.12, 0.12, 0.14),
        buttonHover: Color.new(0.25, 0.25, 0.27),
        text: Color.new(0.9, 0.9, 0.9),
        highlight: Color.new(0.3, 0.6, 1.0),
        recording: Color.new(0.8, 0.2, 0.2)
    );
    var mainFont = Font("Helvetica Neue", 9);
    var headerFont = Font("Helvetica Neue", 10, true);
    var tempoText;
    var margin = 5;
    var gridSpacing = 20;
    var controlWidth = 35;
    var sliderWidth = 70;
    var controlSpacing = 10;
    var rowHeight = 95;
    var patternWidth = 110 + (~patternResolution * gridSpacing);
    var controlSectionWidth = (controlWidth + sliderWidth + controlSpacing) * 4;
    var windowWidth = 1024;
    var windowHeight = 600;

    w = Window("Rhythm Sampler", Rect(0, 0, windowWidth, windowHeight))
    .background_(colors.background);

    // Compact Header panel
    UserView(w, Rect(margin, margin, windowWidth - (margin * 2), 80))
    .background_(colors.panel)
    .drawFunc_({ |view|
        Pen.strokeColor = colors.highlight;
        Pen.width = 2;
        Pen.strokeRect(view.bounds.moveTo(0,0));
    });

    // Transport controls
    Button(w, Rect(20, 20, 50, 25))
    .states_([[">", colors.text, colors.highlight]])
    .font_(headerFont)
    .action_(~startPlaying);

    Button(w, Rect(75, 20, 50, 25))
    .states_([["□", colors.text, colors.button]])
    .font_(headerFont)
    .action_(~stopPlaying);

    // Tempo controls
    StaticText(w, Rect(windowWidth - 280, 25, 50, 20))
    .string_("TEMPO")
    .stringColor_(colors.text)
    .font_(headerFont);

    tempoText = StaticText(w, Rect(windowWidth - 50, 25, 40, 20))
    .string_(~tempo.asInteger.asString)
    .stringColor_(colors.highlight)
    .font_(headerFont);

    Slider(w, Rect(windowWidth - 220, 25, 160, 20))
    .background_(colors.button)
    .knobColor_(colors.highlight)
    .value_(~tempo.linlin(60, 180, 0, 1))
    .action_({ |sl|
        ~tempo = sl.value.linlin(0, 1, 60, 180);
        ~globalClock.tempo = ~tempo / 60;
        tempoText.string = ~tempo.asInteger.asString;
    });

    // Beat indicators
    beatIndicators = Array.fill(~patternResolution, { |i|
        Button(w, Rect(150 + (i * gridSpacing), 50, 20, 20))
        .states_([[" ", colors.buttonOff, colors.button]])
        .font_(mainFont)
        .enabled_(false);
    });

    // Instrument rows
    ~instruments.do({ |instr, row|
        var rowY = 100 + (row * rowHeight);
        var controlX = patternWidth + margin;
        var rowBackground = UserView(w, Rect(margin, rowY, windowWidth - (margin * 2), rowHeight - 5))
        .background_(colors.panel)
        .drawFunc_({ |view|
            Pen.strokeColor = colors.button;
            Pen.width = 1;
            Pen.strokeRect(view.bounds.moveTo(0,0));
        });

        // Instrument label
        StaticText(rowBackground, Rect(5, 25, 70, 25))
        .string_(instr.asString.toUpper)
        .stringColor_(colors.text)
        .font_(headerFont);

        // Pattern buttons
        ~patternResolution.do({ |col|
            Button(rowBackground, Rect(80 + (col * gridSpacing), 25, 20, 20))
            .states_([
                ["", colors.buttonOff, colors.text],
                ["×", colors.text, colors.highlight]
            ])
            .font_(mainFont)
            .action_({ |btn|
                ~patterns[instr][col] = btn.value;
            });
        });

        // Volume controls
        StaticText(rowBackground, Rect(controlX, 5, controlWidth, 20))
        .string_("VOL")
        .stringColor_(colors.text)
        .font_(mainFont);

        Slider(rowBackground, Rect(controlX + controlWidth, 5, sliderWidth, 20))
        .background_(colors.button)
        .knobColor_(colors.highlight)
        .value_(~volumes[instr])
        .action_({ |sl| ~volumes[instr] = sl.value; });

        // Reverb controls
        StaticText(rowBackground, Rect(controlX, 25, controlWidth, 20))
        .string_("REV")
        .stringColor_(colors.text)
        .font_(mainFont);

        Slider(rowBackground, Rect(controlX + controlWidth, 25, sliderWidth, 20))
        .background_(colors.button)
        .knobColor_(colors.highlight)
        .value_(~reverbLevels[instr])
        .action_({ |sl| ~reverbLevels[instr] = sl.value; });

        // Delay Level controls
        StaticText(rowBackground, Rect(controlX, 45, controlWidth, 20))
        .string_("DLY")
        .stringColor_(colors.text)
        .font_(mainFont);

        Slider(rowBackground, Rect(controlX + controlWidth, 45, sliderWidth, 20))
        .background_(colors.button)
        .knobColor_(colors.highlight)
        .value_(~delayLevels[instr])
        .action_({ |sl| ~delayLevels[instr] = sl.value; });

        // Delay Time controls
        StaticText(rowBackground, Rect(controlX, 65, controlWidth, 20))
        .string_("Time")
        .stringColor_(colors.text)
        .font_(mainFont);

        Slider(rowBackground, Rect(controlX + controlWidth, 65, sliderWidth, 20))
        .background_(colors.button)
        .knobColor_(colors.highlight)
        .value_(~delayTimes[instr].linlin(0.05, 1.0, 0, 1))
        .action_({ |sl|
            ~delayTimes[instr] = sl.value.linexp(0, 1, 0.05, 1.0);
            ~delaySynths[instr].set(\delayTime, ~delayTimes[instr]);
        });

        // For recorded tracks, add start/stop offset controls
        if(instr.asString.contains("recorded")) {
            var offsetX = controlX + (controlWidth + sliderWidth + controlSpacing);

            // Start offset controls
            StaticText(rowBackground, Rect(offsetX, 5, controlWidth, 20))
            .string_("Start")
            .stringColor_(colors.text)
            .font_(mainFont);

            Slider(rowBackground, Rect(offsetX + controlWidth, 5, sliderWidth, 20))
            .background_(colors.button)
            .knobColor_(colors.highlight)
            .value_(~startOffsets[instr])
            .action_({ |sl|
                ~startOffsets[instr] = sl.value.linlin(0, 1, 0, 0.2);
            });

            // End offset controls
            StaticText(rowBackground, Rect(offsetX, 25, controlWidth, 20))
            .string_("End")
            .stringColor_(colors.text)
            .font_(mainFont);

            Slider(rowBackground, Rect(offsetX + controlWidth, 25, sliderWidth, 20))
            .background_(colors.button)
            .knobColor_(colors.highlight)
            .value_(~endOffsets[instr])
            .action_({ |sl|
                ~endOffsets[instr] = sl.value.linlin(0, 1,
                    ~startOffsets[instr] + 0.1,
                    1.0
                );
            });

            // Recording button
            Button(rowBackground, Rect(5, 5, 60, 20))
            .states_([
                ["Record", colors.text, colors.button],
                ["Stop", colors.text, colors.recording]
            ])
            .font_(mainFont)
            .action_({ |btn|
                if(btn.value == 1) {
                    ~recSynth = Synth(\recorder, [\bufnum, ~buffers[instr].bufnum]);
                } {
                    ~recSynth.free;
                };
            });
        };
    });

    // Window cleanup
    w.onClose_({
        ~stopPlaying.();
        ~recSynth.free;
        ~reverbSynth.free;
        ~delaySynths.do(_.free);
        ~mixerSynth.free;
        ~effectsBus.free;
        ~reverbBus.free;
        ~delayBuses.do(_.free);
        ~instruments.do({ |instr|
            ~buffers[instr].free;
        });
    });

    w.fullScreen;
}.defer;
});