/**
 * Test Bed:
 *
 * 1. Paste in Code
 * 2. Instantiate the synth in the `x` variable
 * 3. Use the MIDI callbacks to map controls onto synth settings
 * 4. Test a single parameter at a time. Listen by ear to what it does and see how useful it is
 *    If not very useful, find a constant that sounds best to the ear.
 * 5. Repeat for the other parameters
 */

(
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


//MIDI Setup
(
MIDIClient.init;
MIDIIn.connect;
)

//Set up a test run
(
x = Synth.new(\rain);

//Callback when a note is pressed
MIDIIn.noteOn = {
    arg src, chan, midinote, velocity;
    x.set(\rain_cutoff, midinote.midicps);
    midinote.midicps.postln;
};

//On Pitch bend event, adjust the frequency
MIDIIn.bend = {
    arg src, chan, bend;
    var scaled;
    var normalized = bend.linlin(0, 16383, -1, 1);
    //normalized.postln;
    scaled = normalized.linlin(0, 1, 10, 180);
    x.set(\droplet_mean, scaled);
    scaled.postln;
};

MIDIIn.control = {
    arg src, chan, num, val;
    switch(num,
        //Mod wheel
        1, {
            var scaled;
            var normalized = val.linlin(0, 127, 0, 1);
            //normalized.postln;
            scaled = normalized * 0.25;
            x.set(\rain_variation_mean, scaled);
            scaled.postln;
        },
        //Volume Slider
        7, {
            var scaled = 0;
            var normalized = val.linlin(0, 127, 0, 1);
            //normalized.postln;
            scaled = normalized.linlin(0, 1, 10, 180);
            x.set(\droplet_mean, scaled);
            scaled.postln;
        }
    );
};
)