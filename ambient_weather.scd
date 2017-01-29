
(

/**
*/
SynthDef(\sunny_ocean, {
arg crackle_amp = 0.5,
	crackle_den = 70,
	white_amp = 0.1,
	one_coef  = 0.7,
	freq_range = (4..7);
var sig;

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
    arg droplet_mean = 40,
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
)

//ocean synth


//OSC setup
(
//Create the synths
~rain = Synth.new(\rain);
~ocean = Synth.new(\sunny_ocean);
OSCdef.new(
    \temperature,
    {
        arg msg, time, addr, port;
        msg.postln;
        //~rain.set(\droplet_mean, msg[1].linlin(0, 1, 10, 180));
		~ocean.set(\crackle_den, 100*msg[1]);
	},
    '/weather/temperature'
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
)

