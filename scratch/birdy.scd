//Modified from http://sccode.org/1-4Wd
(
Ndef(\birdy, {arg freq=1500, amp=0.5, rate=10;
	var osc, son, convIn, rand;
	osc=LFCub;
	rand = LFNoise1.ar(rate);
	convIn=LinCongN.ar(rate);
	son = osc.ar(Convolution.ar(convIn,convIn));
	freq = Latch.kr(rand.range(0,1).round(0.1), rand) * freq;
	freq = osc.ar(osc.ar(rand)*rand.range(0,10)).range(freq, freq*3);
	son = Formlet.ar(son, freq, convIn.abs*0.1, rand.abs);
	son = Normalizer.ar(son, 0.9, 0.1) * convIn.abs * LFPulse.kr(LFPulse.kr(rand.abs), 0, rand.abs);
	son = son + GVerb.ar(son, 99, 2, mul: rand.range(0,0.3));
	son * amp
}).play
)

(
{
    arg freq = 1500;
    var sig, rand;
    rand = LFNoise1.ar(10);
    sig = LFCub.ar(LFCub(rand) * rand.range(0, 10)).range(freq, 3 * freq);
    sig = Formlet.ar(sig, freq);
    sig = Normalizer.ar(sig, 0.9, 0.1);
    0.5 * sig;
}.play;
)

//Happy accident. use it for wind?
(
{
    var sig = OnePole.ar(WhiteNoise.ar(0.1)+Dust.ar(100, 0.5), 0.7);
    sig = 3.0 * LPF.ar(sig, 900);
    sig = FreqShift.ar(sig, 2000 * LFPar.ar(0.1));
    //sig = sig * LFPar.ar(0.01);
    //sig = FreqShift.ar(sig, 1/(4..7));
    //sig = FreqShift.ar(x, 1/(4..7));

//x = x + Splay.ar(FreqShift.ar(x, 1/(4..7)));
    sig.dup;
}.freqscope
)

(
{
    var sig = OnePole.ar(WhiteNoise.ar(0.1)+Dust.ar(100, 0.5), 0.7);
    sig = 3.0 * LPF.ar(sig, 2000);
    sig = FreqShift.ar(sig, 200 * LFPar.ar(0.01));
    //sig = sig * LFPar.ar(0.01);
    //sig = FreqShift.ar(sig, 1/(4..7));
    //sig = FreqShift.ar(x, 1/(4..7));

//x = x + Splay.ar(FreqShift.ar(x, 1/(4..7)));
    sig.dup;
}.freqscope
)

(
{
x = OnePole.ar(WhiteNoise.ar(0.1)+Dust.ar(100, 0.5), 0.7);
x = x + Splay.ar(FreqShift.ar(x, 1/(4..7)));
}.play
)