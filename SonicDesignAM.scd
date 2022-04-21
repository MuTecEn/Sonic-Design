// Welcome to Sonic Design Seminar 2022!

// Are you ready for your electroacoustic music travel?

o = Buffer.read(s, "C:/Users/user/Desktop/sounds/violins.wav");

// It all started in the middle of the 19th century..

// Additive Synthesis (based on Fourier Theorem)

// Starting with one oscillator

a = NodeProxy.new.play;
a.fadeTime = 2;
a.source = { FSinOsc.ar(freq: 262, mul:0.5)};

// Adding 4 oscillators

(

a.source = { Mix.ar(FSinOsc.ar(freq: [207,261,311,415],mul: 0.2)) };

SystemClock.sched(20, {
  a.source = { Mix.ar(FSinOsc.ar(freq: [311,392,466,622],mul: 0.2)) };
  "wait 20 secs".postln;
} );

SystemClock.sched(40, {
	a.source = { Mix.ar(FSinOsc.ar(freq: [233,293,349,466],mul: 0.2))};
  "wait 40 secs".postln;
} );

SystemClock.sched(60, {
	a.source = { Mix.ar(FSinOsc.ar(freq: [174,220,261,349],mul: 0.2))};
  "wait 60 secs".postln;
} );

SystemClock.sched(80, {
	a.source = { Mix.ar(FSinOsc.ar(freq: [207,261,311,415],mul: 0.2))};
  "wait 80 secs".postln;
} );

SystemClock.sched(100, { a.free; "wait 100 secs".postln; });

);

// This era is called Early Electroacoustic (1948-1960)

// Let's take a train back in time and imagine we are in Europe..

//...and more specifically, in the NWDR studio in Germany!

// In Cologne, Elektronische Musik was born..

// Herbert Eimert - serialism
// (based on Schoenberg's 12-tone technique)

(
{
    var sig, noiseLfo;
    noiseLfo = LFNoise1.kr(50);
    sig = Mix.ar(LFTri.ar(freq: [262, 277.2, 293.7, 311, 329.6, 349.2, 370, 392, 415.3, 440, 466.2, 493.9, 523.3], mul: LFPulse.ar(freq: noiseLfo.range(0.5,15), width: 0.4)));
    sig = LPF.ar(sig, noiseLfo.range(262, 523));
    sig = FreeVerb.ar(sig);
    Out.ar(0, Pan2.ar(sig, noiseLfo.range(1,-1)) * 0.2);
}.play;
)

x = Pbind(\instrument, \default, \freq, 262, \dur, 0.5 ).play;

a = Pseq(list: [262, 277.2, 293.7, 311, 329.6, 349.2, 370, 392, 415.3, 440, 466.2, 493.9, 523.3], repeats: inf);


// Karlheinz Stockhausen - Aleatory Techniques
// some musical aspects are left to chance

x = Pbind(\instrument, \default, \freq, a, \dur, 0.5 ).play;

a = Prand(list: [262, 277.2, 293.7, 311, 329.6, 349.2, 370, 392, 415.3, 440, 466.2, 493.9, 523.3], repeats: inf);

x = Pbind(\instrument, \default, \freq, a, \dur, 0.5 ).play;

// ..and now let's visit Paris, France!

(
SynthDef(\impulse, {
  arg out = 0, amp = 0.8;
  var sig, freq, env;
    env = XLine.kr(1,0.01,0.5,doneAction:2);
	freq = XLine.kr(60,523,0.5,doneAction:0);
	sig = Pulse.ar(freq)*env;
  Out.ar(out, amp * sig);
}).add;
)

y = Synth(\impulse);
c = NodeProxy.new.play;
c.fadeTime = 2;
c.source = Pbind(\instrument, \impulse).play;
c.clear(3)

// Here we will meet Musique Concrete

(
SynthDef.new(\sustained,{
	var temp, sum ,env, freq;
	sum = 0;
	env = EnvGen.kr(
		Env.perc(0.01,5,0.3,-2),
		doneAction:2
	);
	freq = XLine.kr(60,523,0.5,mul:0.3, doneAction:0);
		10.do{
			temp = Pulse.ar(freq)*env;
			sum = sum + temp;
		};
		sum = sum *0.05;
		Out.ar(0,sum);
}).add;
)

x = Synth.new(\sustained);

(

SystemClock.sched(8, {
  x = Synth.new(\sustained);
  "wait 8 secs".postln;
} );

SystemClock.sched(16, {
	x = Synth.new(\sustained);
  "wait 16 secs".postln;
} );

SystemClock.sched(24, {
	x = Synth.new(\sustained);
  "wait 24 secs".postln;
} );

SystemClock.sched(32, {
	x = Synth.new(\sustained);
  "wait 32 secs".postln;
} );

SystemClock.sched(40, { x.free; "wait 40 secs".postln; });

);

// The 'polar opposite' of Elektronische Musik

// (iterative sound under construction)

// Pierre Schaeffer - Sampling

(
SynthDef(\slicer, {
  arg out = 0, amp = 0.8, t = 2;
  var trig, beat, pos, sig, direction, beatList;
  beatList = (0..31);
    trig = Impulse.kr( t / (o.duration / beatList.size) );
   beat =TChoose.kr( trig, beatList );
    pos = beat  * (o.numFrames / beatList.size);
  direction = TWChoose.kr(trig, [-1, 1], [0.5, 0.3]);
  sig = PlayBuf.ar(2, o, direction, trig, pos);
  Out.ar(out, amp * sig);
}).add;
)

~player1 = Synth(\slicer, [\bufnum, o]);
~player1.set(\t, 4);

// Let's take a trip to USA!

// John Cage

// ctlr + .

// 4:23 minutes later..

// Moving on to the Electroacoustic Music Evolution (1960-1990)

(
SynthDef("MyBass", { arg freq = 40, sustain = 1, amp = 0.06, att = 0.1, rel = 2, lofreq = 1000, hifreq = 3000;
    var env, snd;
    snd = Saw.ar(freq: freq * [0.99, 1, 1.001, 1.008]);
	snd = LPF.ar(
		in: snd,
		freq: LFNoise2.kr(1).range(lofreq, hifreq)
	);
    snd = Splay.ar(snd);
    Out.ar(0, snd);
}).add;
)

~playMyBass = Synth(\MyBass);

// Sound spatialization

// (multichannel expansion under construction)

// Xenakis - Stochastic Music -- (FIND A WAY TO STOP!)

(
h = {Pan2.ar(
Normalizer.ar(
RLPF.ar(
RLPF.ar(Gendy2.ar(a:SinOsc.kr(0.4,0,0.05,0.05),c:SinOsc.kr(0.3,0,0.1,0.5)),
MouseX.kr(10,10000,'exponential'),0.05),
MouseY.kr(10,10000,'exponential'),0.05)
,0.9)
,Lag.kr(LFNoise0.kr(1),0.5))}.play;
)

// ..and we are in the Digital Age! (1990-)

// Post-Schaefferian Electronica
// Noise

b = NodeProxy.new.play;
b.fadeTime = 2;
b.source = {WhiteNoise.ar(0.05,0)};

// a hi-hat sound using white noise and a resonant high-pass filter
c = NodeProxy.new.play;
c.fadeTime = 2;
c.source = { var hihat, env; hihat = RHPF.ar(in: WhiteNoise.ar(0.1), freq: 9000, rq: 0.4); env = EnvGen.kr(envelope: Env.perc(0.01, 0.4), gate: Impulse.kr(2)); hihat.dup * env * 0.4};



// microsounds (glitches)

(
SynthDef(\glitch,
{
arg rate = 1, freq = 60, index = 1000, tRate = 100,
out = 0, fRate = 0.1;

var t_trig = LFPulse.kr(0.5/fRate, 0.5, mul: 0.1);
var random = LFNoise0.ar(rate,0.1, 1);
var noise = Hasher.ar(random);
var sound = Saw.ar((freq+(noise*index)), Decay.kr(Impulse.kr(tRate), noise*0.001)).tanh;
sound = Pan2.ar(sound, noise-0.3*2);
FreeSelf.kr(t_trig);
Out.ar(out, sound);
}).store;
)


z = Pbind(\instrument, \glitch,\dur, 20,\rate, Pfuncn{261.rand},\freq, Pfuncn{1046.rand},\index, Pfuncn{523.rand},\tRate, Pfuncn{1100.rand},\fRate, 5).play;


// Ambience

(
SynthDef("klankPink", {
    var excitation, signal, env, panner;
    excitation = PinkNoise.ar(0.008);
    signal = Klank.ar(
        `[[200, 200*1.19, 200*1.5, 200*2, 200*4],
            nil,
            [1,1, 1, 1,1]],
        excitation);
    env = EnvGen.kr(Env.adsr, doneAction: 2);
    panner = LFDNoise1.kr(0.5);
    Out.ar(0, Pan2.ar(signal * env, panner));
}).add;
)

~nice = Synth("klankPink");


// Soundscape

d = NodeProxy.new.play;
d.fadeTime = 2;
d.source = { Mix.fill(10,{var freq; freq= rrand(130,160.3);  Pan2.ar(SinOsc.ar(Gendy2.ar(6.rand,6.rand,SinOsc.kr(0.1,0,0.49,0.51),SinOsc.kr(0.13,0,0.49,0.51),freq ,freq, SinOsc.kr(0.17,0,0.49,0.51), SinOsc.kr(0.19,0,0.49,0.51),12, 12, 0.4.rand, 0.4.rand, 200, 400), 0, 0.1), 1.0.rand2)})};

// fade the sound out

// Thank you, I hope you enjoyed your trip!