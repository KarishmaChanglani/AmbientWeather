/**
 * Synth that makes the cricket sounds.
*/
(
SynthDef(\crickets, {
	arg crickets_per_second = 0.5;
	var trig, seq, demand, sig;

    crickets_per_second = (crickets_per_second - 0.37) * 100 + 15;

	// instead of [metro], Impulse.kr is used here. Delta t = 17 ms equates to 58.82 Hz.
	trig = Impulse.kr(crickets_per_second);

	// the main idea of the following line was to use an approach
	// that uses the same coefficients as described in the pd patch
	seq = Dseq(Array.fill(41, {|i| if(i<7, {(i+2)/9},{0}) }),inf);
	demand = Demand.kr(trig,0,seq);

	// Pure data seemed to slightly disobey its own specifications,
	// so I analysed the waveform and came up with this:
	sig = EnvGen.ar(Env.new([0, 1, 0], [4/44100, 0]), trig) * demand;


	sig = OnePole.ar(sig, exp(-2pi * (1000 * SampleDur.ir)));
	sig = (
			// changed the Q factor of the first 3 BPFs to approximate farnells sound
			BPF.ar(sig, 4500 + ((0..2)*50), 300.reciprocal, 100)).sum
			+ BPF.ar(sig, 9000, 500.reciprocal, 42);
	sig = ((sig - OnePole.ar(sig, exp(-2pi * (4000 * SampleDur.ir)))) * 0.7)!2;
	Out.ar(sig, sig);
}).add;

/**
 * Synth that makes ocean sounds.
 * Modifiend from code spippet "http://sccode.org/1-1n"
 */
SynthDef(\ocean, {
arg crackle_amp = 0.5,
	crackle_den = 0.7,
	white_amp = 0.1,
	one_coef  = 0.7,
	freq_range = (4..7);
var sig;

    crackle_den = 100 * crackle_den;

sig = OnePole.ar(WhiteNoise.ar(white_amp)+Dust.ar(crackle_den, crackle_amp), one_coef);
sig = sig + Splay.ar(FreqShift.ar(sig, 1/freq_range));

	Out.ar(0, sig);
}).add;


/**
 * Synth that makes rain sounds.
 * Modified from code snippet http://sccode.org/1-e
 */
SynthDef(\rain, {
    //Parameters for controlling the 'droplets' part of the rain sound (a crackle sound)
    //Average number of droplet pulses per second.
    arg droplet_mean = 0.2,
    //droplet pulses per second is randomly selected from [mean - spread, mean + spread]
    droplet_spread = 5,
    //Low-pass cutoff frequency for the droplet
    droplet_cutoff = 4700,

    //Parameters for controlling the main rain pink noise sound. (think sheets of rain)
    //average rain amplitude
    rain_variation_mean = 0.08,
    //spread of rain amplitude
    rain_variation_spread = 0.02,
    //High-pass cutoff frequency for the droplet
    rain_cutoff = 400,

    //Reverb settings
    reverb_room_size = 250,
    reverb_time = 100,
    reverb_damping = 0.25,
    reverb_dry_percent = 0.3,

    //How long it takes for the rain to fade in
    fade_in_time = 15;

    //SuperCollider requires all variables to be declared up front :(
    var sig,
    droplet_filter, droplet, droplet_density,
    rain_noise_amp, rain_noise, rain_filter,
    rain_reverb;


    //Scale the OSC parameter
    droplet_mean = droplet_mean.linlin(0, 1, 10, 180);

    //Randomly choose a droplet pulse density from a range of
    //[mean - spread, mean + spread]
    droplet_density = LFNoise1.kr(freq: 0.2).range(
        droplet_mean - droplet_spread,
        droplet_mean + droplet_spread);

    //Generate the droplet sound
    droplet = Dust2.ar(droplet_density);
    droplet_filter = LPF.ar(droplet, droplet_cutoff);

    //Vary the pink noise rain amplitude randomly
    rain_noise_amp = LFNoise1.kr(freq: 0.03).range(
        rain_variation_mean - rain_variation_spread,
        rain_variation_mean + rain_variation_spread);
    rain_noise = PinkNoise.ar(mul: rain_noise_amp);

    //Filter the rain noise + droplet signal
    rain_filter = HPF.ar(rain_noise + droplet_filter, rain_cutoff);

    //Add Reverb
    rain_reverb = GVerb.ar(
        rain_filter,
        reverb_room_size,
        reverb_time,
        reverb_damping,
        drylevel: reverb_dry_percent);

    //Output the final signal
    sig = rain_reverb * Line.kr(dur: fade_in_time);
    Out.ar(0, sig.dup);
}).add;

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

//ocean synth


//OSC setup
(
~synth_list = [
    \rain,
    \ocean,
    \cricket
];
~param_names = [
    \droplet_mean,
    \crackle_den,
    \crickets_per_second
];

~noise_synth = nil;
~synth_index = nil;

//Create the synths
//~rain = Synth.new(\rain);
//~ocean = Synth.new(\ocean);
//~crickets = Synth.new(\crickets);
OSCdef.new(
    \temperature,
    {
        arg msg, time, addr, port;
        msg.postln;

        ~noise_synth.set(~param_names[~synth_index], msg[1]);


        /*
        ~rain.set(\droplet_mean, msg[1].linlin(0, 1, 10, 180));
		~ocean.set(\crackle_den, 100*msg[1]);
		~crickets.set(\temp, (msg[1]-0.37)*100+15)
        */
	},
    '/weather/temperature'
);

OSCdef.new(
    \conditions,
    {
        arg msg, time, addr, port;
        msg.postln;

        if (~noise_synth.notNil, {
            ~noise_synth.free;
        });
        ~synth_index = msg[1];
        ~noise_synth = Synth.new(~synth_list[~synth_index]);
    },
    '/weather/conditions'
);

OSCdef.new(
    \precipitation,
    {
        arg msg, time, addr, port;
        msg.postln;
        ~rain.set(\rain_variation_mean, 0.25 * msg[1]);
    },
    '/weather/precipitation'
);

//Create the synths
~weather = nil;
OSCdef.new(
    \warmth,
    {
        arg msg, time, addr, port;
        msg.postln;


        if (~weather.notNil, {
            ~weather.stop;
        });
        ~weather = ~make_pattern.value(msg[1]).play(quant: 1.0);
    },
    '/weather/warmth'
);
)