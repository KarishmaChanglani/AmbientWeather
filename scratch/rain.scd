{WhiteNoise.ar(mul: 0.2).dup}.play;

x = { {WhiteNoise.ar}.dup(12).mean.dup * 0.5}.play;

(
{
    Limiter.ar(
        tanh(
            3 * GVerb.ar(
                HPF.ar(
                    PinkNoise.ar(
                        0.08+LFNoise1.kr(0.3,0.02))+LPF.ar(Dust2.ar(LFNoise1.kr(0.2).range(40,50)),7000),
                    400
                ),
                250,100,0.25,drylevel:0.3
            ) * Line.kr(0,1,2)
        ) /*+ (
            GVerb.ar(
                LPF.ar(
                    10 * HPF.ar(PinkNoise.ar(LFNoise1.kr(3).clip(0,1)*LFNoise1.kr(2).clip(0,1) ** 1.8), 20)
                    ,LFNoise1.kr(1).exprange(100,2500)
                ).tanh,
               270,30,0.7,drylevel:0.5
            ) * Line.kr(0,0.7,30)
        ) */
    )
}.freqscope;
)


//http://sccode.org/1-e
(
{
    Limiter.ar(
        tanh(
            3 * GVerb.ar(
                HPF.ar(
                    PinkNoise.ar(0.08+LFNoise1.kr(0.3,0.02))+LPF.ar(Dust2.ar(LFNoise1.kr(0.2).range(40,200)),7000),
                    400
                ),
                250,100,0.25,drylevel:0.3
            ) * Line.kr(0,1,10)
        ) /*+ (
            GVerb.ar(
                LPF.ar(
                    10 * HPF.ar(PinkNoise.ar(LFNoise1.kr(3).clip(0,1)*LFNoise1.kr(2).clip(0,1) ** 1.8), 20)
                    ,LFNoise1.kr(1).exprange(100,2500)
                ).tanh,
               270,30,0.7,drylevel:0.5
            ) * Line.kr(0,0.7,30)
        ) */
    )
}.freqscope;
)

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
    droplet_cutoff = 7000,

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
    fade_in_time = 3;

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

x = Synth.new(\rain);
x.set(\droplet_cutoff, MouseX.kr(400, 9000));
x.set(\droplet_cutoff, 9000);
x.plot;



//droplet component
(
{
    var mid_density = MouseX.kr(50, 300);
    var density_amp = 10;
    var filter_freq = 7000;
    LPF.ar(Dust2.ar(LFNoise1.kr(freq: 0.1).range(mid_density - density_amp, mid_density + density_amp)), filter_freq);
}.plot;
)

{PinkNoise.ar(0.08+LFNoise1.kr(0.3,0.02))}.plot;

{PinkNoise.ar(LFNoise1.kr(0.3).range(0.08 - 0.02, 0.08 + 0.02))}.play;


{Line.kr(0,1,10)}.plot;
(
{
    3 * GVerb.ar(
                HPF.ar(
                    PinkNoise.ar(
                        0.08+LFNoise1.kr(0.3,0.02))+LPF.ar(Dust2.ar(LFNoise1.kr(0.2).range(40,50)),7000),
                    400
                ),
                250,100,0.25,drylevel:0.3
            ) * Line.kr(0,1,10)
}.plot;
)

{0.2 * SinOsc.ar(440) * Line.kr(0, 1, 2)}.plot;


(
{
    Limiter.ar(
        tanh(
            3 * Pulse.ar(440, mul: 0.25) * Line.kr(0,1,2)
        )
    )
}.scope;
)