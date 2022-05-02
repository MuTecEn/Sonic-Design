// Welcome to Sonic Design Seminar 2022!

// Are you ready for your electroacoustic music trip?


s.volume = -12; // to avoid distortion


a = NodeProxy.new.play;
a.fadeTime = 2;
a.source = { var trigger, carrier, modulator, envelope; trigger = Impulse.kr(0.5); envelope = Linen.kr(gate: trigger, attackTime: 1.2, susLevel: 0.5, releaseTime: 0.7);carrier = Mix.ar(FSinOsc.ar( freq: [ 50, 52, 59, 62 ].midicps)); Out.ar([0, 1], carrier * envelope * 0.1);};


// load our buffers

o = Buffer.read(s, "C:/Users/user/Desktop/sounds/Hist1.wav");
q = Buffer.read(s, "C:/Users/user/Desktop/sounds/untitled.wav");


// load our Synths

// piano synth

(
SynthDef(\piano, {
  arg freq = 50, index = 0.7, release = 4;
  var modFreq1, modFreq2, depth1, depth2, envelope, modulators, fm;
  modFreq1 = freq * 0.5;
  modFreq2 = freq * 4;
  index = 0.7;
  depth1 = modFreq1 * index;
  depth2 = modFreq2 * index;
  envelope = EnvGen.kr(Env.perc(attackTime: 0,releaseTime: release, curve: -4), doneAction:2);
  modulators = SinOsc.ar(modFreq1, mul: depth1) + SinOsc.ar(modFreq2, mul: depth2);
  fm = SinOsc.ar(freq + modulators, mul: envelope);
  Out.ar([0, 1], fm * 0.3);
}).add;
);


// bell Synth

(
SynthDef(\bell,
{   var partials, env;
    partials = SinOsc.ar(freq:262,mul: 0.3)+
    SinOsc.ar(freq:277,mul: 0.25)+
    SinOsc.ar(freq:340,mul: 0.1)+
    SinOsc.ar(freq:385,mul: 0.2)+
    SinOsc.ar(freq:605,mul: 0.3)+
    SinOsc.ar(freq:670,mul: 0.1)+
    SinOsc.ar(freq:812,mul: 0.1);
    env = XLine.ar(start: 0.5, end: 0.0001, dur: 10);
    Out.ar([0, 1], partials * env);
}).add;
);

// string synth

(
SynthDef(\string, { arg i_out, freq = 260, gate = 1, pan, amp=0.1;
    var out, eg, fc, osc, a, b, w;
    fc = LinExp.kr(LFNoise1.kr(Rand(0.25, 0.4)), -1, 1, 500, 2000);
    osc = Mix.fill(8, {LFSaw.ar(freq * [Rand(0.99, 1.01), Rand(0.99, 1.01)], 0, amp) }).distort * 0.2;
    eg = EnvGen.kr(Env.asr(1, 1, 1), gate, doneAction: Done.freeSelf);
    out = eg * RLPF.ar(osc, fc, 0.1);
    #a, b = out;
    Out.ar(i_out, Mix.ar(PanAz.ar(4, [a, b], [pan, pan+0.3])));
}).add;
)

// sampling synth

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

// chorus synth

(
SynthDef(\chorus, {
  arg  buf,  rate1 = 5, rate2 = 5.1, rate3 = 5.2, wet = 1;
  var sig, delay1, delay2, delay3, bankOfDelays, out;
  sig = PlayBuf.ar(1, buf, loop:1);
  delay1 = DelayL.ar(sig, delaytime: SinOsc.kr(rate1, mul: 0.001, add: 0.03));
  delay2 = DelayL.ar(sig, delaytime: SinOsc.kr(rate2, mul: 0.001, add: 0.022));
  delay3 = DelayL.ar(sig, delaytime: LFTri.kr(rate3, mul: 0.001, add: 0.027));
  bankOfDelays = delay1 + delay2 + delay3;
  out = sig + (bankOfDelays * wet);
  Out.ar([0, 1], out);
}).add;
)


// impulsive sound synth

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


// sustained sound synth

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


// bass synth

(
SynthDef(\bass, { arg freq = 40, sustain = 1, amp = 0.08, att = 0.1, rel = 5, lofreq = 1000, hifreq = 3000;
    var env = Line.kr(start: 0.7, end: 0, dur: 10), snd;
    snd = Saw.ar(freq: freq * [0.99, 1, 1.001, 1.008], mul: env);
	snd = LPF.ar(
		in: snd,
		freq: LFNoise2.kr(1).range(lofreq, hifreq)
	);
    snd = Splay.ar(snd);
    Out.ar(0, snd);
}).add;
)


// glitches synth

(
SynthDef(\chaosGlitch, {
	arg len = 10, fundFreq = 50, henA = 2, henB = 0.4, t = 1, gate = 1;
	var mainEnv = EnvGen.kr(Env.adsr(len,1), gate, doneAction:2);
	var speed = Array.geom(4, t, [1.75, 1.25].choose);
	var freq = Array.geom(8, fundFreq*2, 1.5);
	var pulse = {|rat1,rat2|LFPulse.ar(rat1, [0,0.5,1].choose)*LFPulse.ar(rat2)};
	var a = Lag.ar(HenonN.ar(
		speed.choose*(mainEnv*10000.rand),
		henA, henB,
	), 0.01);
	var bass = SinOsc.ar(fundFreq!2*(a*1.0.rand), 0, Lag.ar(pulse.(t, speed.choose), 0.001));
	var tone1 = SinOsc.ar([(fundFreq+Rand(0,5))*a,(fundFreq+Rand(0,5))*a], 0, 0.01*pulse.(speed.choose, speed.choose));
	var tone2 = Pan2.ar(SinOsc.ar(freq.choose*a, 0, 0.1*pulse.(speed.choose, t)), a);
	var tone3 = SinOsc.ar([freq.choose,freq.choose*a], 0, 0.05*pulse.(speed.choose, t))*mainEnv.round(0.25);
	var noise = Pan2.ar(PinkNoise.ar(a*0.1*pulse.(t,t)), a);
	var impulse = RLPF.ar(Impulse.ar(pulse.(t, speed.choose), a), freq.choose+(a*10), 0.01, 0.1).tanh;

	Out.ar(0, (bass+tone1+tone2+tone3+noise+impulse).tanh);
	}
).store;
)

// Ambience


(
SynthDef(\ambience, {
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

///////////////////////////////////////////////////////////////////


// It all started in the middle of the 20th century..


///////////////////////////////////////////////////////////////////

b = Synth(\bell);

// Additive Synthesis (based on Fourier Theorem)

// Starting with one oscillator


c = NodeProxy.new.play;
c.fadeTime = 2;
c.source = {FSinOsc.ar(freq:262, mul:0.2)};


// Adding 4 oscillators


(
c.source = {Mix.ar(FSinOsc.ar(freq:[155,196,246,293], mul:0.2))};

SystemClock.sched(10, {c.source = {Mix.ar(FSinOsc.ar(freq:[246,277,293,349], mul:0.2))};});

SystemClock.sched(20, {c.source = {Mix.ar(FSinOsc.ar(freq:[146,174,261,277], mul:0.2))};});

SystemClock.sched(30, {c.clear(5)};);
)


///////////////////////////////////////////////////////////////////


// This era is called Early Electroacoustic (1948-1960)
// Let's take a train back in time and imagine we are in Europe..
//...and more specifically, in the NWDR studio in Germany!
// In Cologne, Elektronische Musik was born..


///////////////////////////////////////////////////////////////////

// Herbert Eimert - serialism
// (based on Schoenberg's 12-tone technique)


// inspired by Klangstudie II


d = NodeProxy.new.play;
d.fadeTime = 2;
d.source = {f = LFSaw.kr(0.4, 0, 24, LFSaw.kr([8,7.23], 0, 3, 80)).midicps;	CombN.ar(SinOsc.ar(f,0,0.04), 0.2, 0.2,4)};
d.clear(5);


e = NodeProxy.new.play;
e.fadeTime = 2;
e.source = { var sig, noiseLfo; noiseLfo = LFNoise1.kr(50); sig = Mix.ar(LFTri.ar(freq: [262, 277.2, 293.7, 311, 329.6, 349.2, 370, 392, 415.3, 440, 466.2, 493.9, 523.3], mul: LFPulse.ar(freq: noiseLfo.range(0.5,15), width: 0.4))); sig = LPF.ar(sig, noiseLfo.range(262, 523)); sig = FreeVerb.ar(sig); Out.ar(0, Pan2.ar(sig, noiseLfo.range(1,-1)) * 0.2);};


x = Pbind(\instrument, \piano, \freq, 262, \dur, 0.5).play;


///////////////////////////////////////////////////////////////////

// Karlheinz Stockhausen - Aleatory Techniques
// some musical aspects are left to chance

p = Prand(list: [262, 277.2, 293.7, 311, 329.6, 349.2, 370, 392, 415.3, 440, 466.2, 493.9, 523.3], repeats: inf );

y = Pbind(\instrument, \piano, \freq, p, \dur, 0.5).play;

y.stop;

// integral serialism

r = Prand(list: [\piano,\string,\bell], repeats: inf);

z = Pbind(\instrument, r, \freq, p, \dur, 0.5).play;

x.stop;

///////////////////////////////////////////////////////////////////

// ..and now let's visit Paris, France!

// Here we will meet Musique Concrète

// The 'polar opposite' of Elektronische Musik

///////////////////////////////////////////////////////////////////


// Pierre Schaeffer - Sampling

// inspired by Symphonie pour un homme seul

~player1 = Synth(\chorus, [\bufnum, q]);

~player1.free;

~player2 = Synth(\slicer, [\bufnum, o]);


f = Synth(\impulse);

z.stop;

~player2.set(\t, 8);

g = Synth(\sustained);

h = NodeProxy.new.play;
h.fadeTime = 2;
h.source = {BPZ2.ar(WhiteNoise.ar(LFPulse.kr(MouseX.kr(0.2,50), 0, 0.25, 0.1)))};
h.clear(3);

e.clear(5);

///////////////////////////////////////////////////////////////////

// Moving to the USA

// Steve Reich - Phase Shifting

~freqs=[64, 66, 71, 73, 74, 66, 64, 73, 71, 66, 74, 73].collect(_.midicps);
~time=0.25;

~steady=Routine({var i=0;{var pitch=~freqs[i%12];Synth(\piano, [freq:pitch,pan:-0.4]);	i=i+1;0.25.wait;}.loop;});

~phasing=Routine({var i=0, phase=0;	{var pitch=~freqs[i%12];Synth(\piano, [freq:pitch, pan:0.4]);i=i+1;if (rrand(0, 80)==0, {			~time=0.24;phase=i;});if (i-phase==25, {phase=0;~time=0.25;});		~time.wait;}.loop;});

~inst1=~steady.play;
~inst2=~phasing.play;
~inst3 = ~phasing.play;

// John Cage

// transition inspired by 4:33


a.clear(5);
q.play;

~inst2.stop;
~inst1.stop;
~player2.free;

///////////////////////////////////////////////////////////////////

// Moving on to the Electroacoustic Music Evolution (1960-1990)


~player2 = Synth(\bass);


///////////////////////////////////////////////////////////////////


// Xenakis - Stochastic Music
// watch the cursor!

i = NodeProxy.new.play;
i.fadeTime = 2;
i.source = { var f, p, z, offset; f = 50; p = 20; z = 0.0; offset = Line.kr(0, -0.02, 60); p.do({ arg i; z = FSinOsc.ar( f * (i+1),0, max(0, LFNoise1.kr( 6 + [4.0.rand2, 4.0.rand2],  0.02, ) ), z ) }); z };


// inspired by Diamorphoses


j = NodeProxy.new.play;
j.fadeTime = 2;
j.source  = {Pan2.ar(Normalizer.ar(RLPF.ar(RLPF.ar(Gendy2.ar(a:SinOsc.kr(0.4,0,0.05,0.05),c:SinOsc.kr(0.3,0,0.1,0.5)),MouseX.kr(10,10000,'exponential'),0.05),MouseY.kr(10,10000,'exponential'),0.05),0.9),Lag.kr(LFNoise0.kr(1),0.5))};


///////////////////////////////////////////////////////////////////

// ..and we are in the Digital Age! (1990-)

// Post-Schaefferian Electronica
// Noise

k = NodeProxy.new.play;
k.fadeTime = 2;
k.source = {WhiteNoise.ar(0.05,0)};



// a hi-hat sound using white noise and a resonant high-pass filter

k.source = {var hihat, env; hihat = RHPF.ar(in: WhiteNoise.ar(0.1), freq: 9000, rq: 0.4); env = EnvGen.kr(envelope: Env.perc(0.01, 0.4), gate: Impulse.kr(2)); hihat.dup * env * 0.4};


///////////////////////////////////////////////////////////////////

// microsounds (glitches)

l = Pbind(\instrument, \chaosGlitch,\dur, 10,\len, Prand([1, 1.5, 1.75, 2]+10,inf),\henA, Prand([2, 1.3, 1.29, 1.25], inf),	\henB, Prand([0.2, 0.3], inf),\t, Prand([2, 4, 2, 6], inf),\fundFreq, Prand([40, 600, 8000, 200, 600, 6000], inf)).play;


///////////////////////////////////////////////////////////////////

// Ambience


~player3 = Synth(\ambience);


i.clear(5);
j.clear(5);
k.clear(5);
l.stop;


///////////////////////////////////////////////////////////////////

// Soundscape

m = NodeProxy.new.play;
m.fadeTime = 2;
m.source = {Mix.fill(10,{var freq; freq= rrand(130,160.3);  Pan2.ar(SinOsc.ar(Gendy2.ar(6.rand,6.rand,SinOsc.kr(0.1,0,0.49,0.51),SinOsc.kr(0.13,0,0.49,0.51),freq ,freq, SinOsc.kr(0.17,0,0.49,0.51), SinOsc.kr(0.19,0,0.49,0.51),12, 12, 0.4.rand, 0.4.rand, 200, 400), 0, 0.1), 1.0.rand2)})};



~player3.free;
m.clear(5);


l = Synth(\bell);


///////////////////////////////////////////////////////////////////


// Thank you, I hope you enjoyed your trip!


////////////////////////////////////////////////////////////////////


// References
//
// Curtis, R., 1995, The Computer Music Tutorial
// Eastman Audio Research Studio notes, https://www.esm.rochester.edu/ears/docs/supercollider/examples/
// Karamanlis, O., 2021, Σύνθεση και Επεξεργασία Ήχου με το SuperCollider, https://synthesis.orestiskaramanlis.net/
// LaFleur, E., 2020, Programming Steve Reich’s Piano Phase in SuperCollider, https://www.ezralafleur.com/programming-steve-reichs-piano-phase-in-supercollider/
// Rumush, 2015, ChaosGlitch Synth, https://sccode.org/1-50l
// SuperCollider official documentation, https://doc.sccode.org/
// Wilson, S.; Cottle, D.; Collins, N., 2011, The SuperCollider Book, https://mitpress.mit.edu/books/supercollider-book
