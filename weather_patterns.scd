(
/**
 * Pad synth that sounds somewhat like bells
 * Used for the "Warm" and "Hot" patterns
 * Based on "PAD Long Bell" from Syntorial
 */
SynthDef.new(\bell, {
    //Pitch of the note to play
    arg freq = 440,
    //Pulse width. Use a wide pulse width (0.5+)
    pulse_width = 0.8,
    //Filter Freqency
    cutoff = 600,
    //Used to control sustain
    gate = 1;

    var sig, filter_env, amp_env, amp_env_gen;

    //Mix two pulse waves together
    sig = Mix.new([
        Pulse.ar(freq, pulse_width),
        Pulse.ar(2 * freq, pulse_width),
    ]);

    //Apply an envelope with long decay and release
    amp_env = Env.adsr(attackTime: 0, decayTime: 1.890, sustainLevel: 1, releaseTime: 1.890);
    amp_env_gen = EnvGen.kr(amp_env, gate, doneAction: 2);
    sig = 0.3 * amp_env_gen * LPF.ar(sig, cutoff);

    //Output the signal
    Out.ar(0, sig.dup);
}).add;

/**
 * Pad synth for drawn out sounds. Used for
 * the "Cold" pattern
 * Based on "PAD PWM" from Syntorial
 */
SynthDef.new(\pad, {
    //Pitch of the note to play
    arg freq = 440,
    //Filter frequency
    cutoff = 400,
    //Used to control sustain
    gate = 1;

    var sig, pulse_lfo, filter_env, amp_env, amp_env_gen;

    //Apply a LFO to change the pulse width slider
    pulse_lfo = 0.5 + 0.2 * LFTri.kr(0.1);

    //Mix two pulse waves together
    sig = Mix.new([
        Pulse.ar(freq, pulse_lfo),
        Pulse.ar(2 * freq,  pulse_lfo),
    ]);

    //Apply an envelope with long decay and release
    amp_env = Env.adsr(attackTime: 0, decayTime: 1.890, sustainLevel: 1, releaseTime: 1.890);
    amp_env_gen = EnvGen.kr(amp_env, gate, doneAction: 2);
    sig = 0.3 * amp_env_gen * LPF.ar(sig, cutoff);

    //Output the signal
    Out.ar(0, sig.dup);
}).add;
)

(
/**
 * Function to create a pattern
 */
~make_pattern = {
    //warmth value. 0 is Cold, 1 is Warm, 2 is Hot
    arg warmth_index = 0;

    //Select settings
    //Really note offsets in semitones
    var notes = [
       //Cold, minor
       [0, 3,  7, 12],
       //Warm: major
       [0, 4, 7, 12],
       //Hot: like warm but don't go too high
       [0, 4, 7]
    ];
    var root_notes = [
       //Cold
       60,
       //Warm. up a half step just to be diferent
       61,
       //Hot: Up an octave
       60 + 12
    ];
    var durations = [
       //Cold: Nice and slow
       0.5,
       //Warm: A brisk pace
       0.25,
       //Hot: Quite fast
       0.125
    ];
    var instruments = [
        //Cold: Drawn out su
        \pad,
        //Warm: Brighter sound
        \bell,
        //Hot: Same brighter sound
        \bell
    ];

    //Create the pattern
    Pbind(
        //Select the duration of each note
        \dur, durations[warmth_index],
        //Pick a random MIDI pitch
        \midinote, Prand(notes[warmth_index] + root_notes[warmth_index], inf),
        //Select an instrument
        \instrument, instruments[warmth_index]
    )
};
)

//OSC setup
(
//Create the synths
~weather = ~make_pattern.value(0).play(quant: 1.0);
~weather.stop;
OSCdef.new(
    \warmth,
    {
        arg msg, time, addr, port;
        msg.postln;
        ~weather.stop;
        ~weather = ~make_pattern.value(msg[1]).play(quant: 1.0);
    },
    '/weather/warmth'
);
)
