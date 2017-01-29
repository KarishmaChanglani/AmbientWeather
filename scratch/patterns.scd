(
SynthDef.new(\bell, {
    arg freq = 440,
    pulse_width = 0.8,
    cutoff = 400,
    gate = 1;

    var sig, filter_env, amp_env, amp_env_gen;

    //Mix two pulse waves together
    sig = Mix.new([
        Pulse.ar(freq, pulse_width),
        Pulse.ar(2 * freq, pulse_width),
    ]);

    amp_env = Env.adsr(attackTime: 0, decayTime: 1.890, sustainLevel: 1, releaseTime: 1.890);
    amp_env_gen = EnvGen.kr(amp_env, gate, doneAction: 2);
    sig = 0.3 * amp_env_gen * LPF.ar(sig, cutoff);

    Out.ar(0, sig.dup);
}).add;

SynthDef.new(\pad, {
    arg freq = 440,
    cutoff = 400,
    gate = 1;

    var sig, pulse_lfo, filter_env, amp_env, amp_env_gen;

    pulse_lfo = 0.5 + 0.2 * LFTri.kr(0.1);

    //Mix two pulse waves together
    sig = Mix.new([
        Pulse.ar(freq, pulse_lfo),
        Pulse.ar(2 * freq,  pulse_lfo),
    ]);

    amp_env = Env.adsr(attackTime: 0, decayTime: 1.890, sustainLevel: 1, releaseTime: 1.890);
    amp_env_gen = EnvGen.kr(amp_env, gate, doneAction: 2);
    sig = 0.3 * amp_env_gen * LPF.ar(sig, cutoff);

    Out.ar(0, sig.dup);

}).add;
)

(
p = {
    arg season_index = 0;

    var patterns = [
       //Cold, minor
       [0, 3,  7, 12],
       //Warm
       [0, 4, 7, 12],
       //Hot
       [0, 4, 7, 12]
    ];
    var root_notes = [
       60,
       61,
       60 + 12
    ];
    var durations = [
       0.5,
       0.25,
       0.125
    ];
    var instruments = [
        \pad,
        \bell,
        \bell
    ];
Pbind(
    \dur, durations[season_index],
    \midinote, Prand(patterns[season_index] + root_notes[season_index], inf),
    \instrument, instruments[season_index]
)
};
)

x = p.value(0).play(quant:1.0);
x.stop;
x.play;
x.reset;
x.play;

