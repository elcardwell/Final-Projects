// MIDI
(
s.boot;
Server.local.scope(2);
MIDIIn.connectAll
)

(
SynthDef("gravitywang", {arg m = 100, freq = 39.0265, dens = 5, amp = 1, gate = 1;
	var sig, cig, env;
	sig = RLPF.ar(0.1*WeaklyNonlinear.ar(0.1*GravityGrid.ar(Impulse.kr(m), 1.0, LFNoise1.kr(m,0.8),LFNoise1.kr(m,0.8)), 0, 1, 1, 9000), 10000, 0.01);
	cig = TermanWang.ar(2.0+ SinOsc.ar(freq,0,5),Impulse.kr(TRand.kr(0.0, 100.0, Dust.kr(TRand.kr(0.0, 10.0, Dust.kr(dens))))),0.01,0.01,1.0,1.0,1.0,0.4,2.0);
	env = Linen.kr(gate, 0.01, 1, 0.05, doneAction: 0);
	Out.ar(0, Pan2.ar(sig+cig, 0, amp*env))}).add;

SynthDef("fitz", {arg x = 8, y = 0.0001, amp = 1, gate = 1;
	var sig, env;
	env = Linen.kr(gate, 0.01, 1, 0.05, doneAction: 0);
	sig = FitzHughNagumo.ar(Impulse.kr(x),y,y,0.5,0.1,TRand.kr(0.0, 10.0, Dust.kr(x)),TRand.kr(0.0, 10.0, Dust.kr(x)));
	Out.ar(0, Pan2.ar(sig, 0, amp*env))}).add;

SynthDef("bud", { arg imp = 1, amp = 1, gate = 1;
	var sig, env, sf, d, g, f;
	sig = SpruceBudworm.ar(Impulse.kr(imp),0.1,24.8,0.5,initx:LinLin.kr(imp, 0, 50, 0.2, 1.2), inity:LinLin.kr(imp, 0, 50, 0.2, 1.2));
	env = Linen.kr(gate, 0.01, 1, 0.05, doneAction: 0);
	sf = LFNoise0.ar(TRand.kr(0.0, 100.0, Dust2.kr(imp)));
	d = TRand.kr(0.01, 1.0, Dust2.kr(imp / 2));
	g = TRand.kr(0.0, 10.0, Dust2.kr(imp / 2));
    f = Ball.ar(sig * sf, g, d, 0.01);
	Out.ar(0, Pan2.ar(DiodeRingMod.ar(sig, f), 0, amp*env))}).add;

SynthDef("brussels", { arg freq = 1, rate = 0.01, friction = 0.00001, mass = 0.2, amp = 1, gate = 1;
	var sig, env, out;
	sig = Brusselator.ar(Impulse.kr(freq), rate);
	env = Linen.kr(gate, 0.01, 1, 0.05, doneAction: 0);
	out = Friction.ar(sig, friction: friction, mass: LinExp.kr(freq, 1, 50, 0.2, 10));
	Out.ar(0, Pan2.ar(out, 0, amp*env))}).add;

SynthDef("finco", { arg freq = 1, amp = 1, gate = 1;
	var sig, env, mod, cig;
	sig = FincoSprottL.ar(freq, TRand.kr(0.0, 3.0, Dust.kr(10)), TRand.kr(0.0, 1.0, Dust.kr(10))).mean;
	env = Linen.kr(gate, 0.01, 1, 0.05, doneAction: 0);
	mod = LinLin.kr(freq, 0.01, 1000, 1, 2).round;
	cig = WaveLoss.ar(sig, LinLin.kr(freq, 0.01, 1000.0, 0.0, 40.0), 40, mode: mod, mul: 0.1);
	Out.ar(0, Pan2.ar(cig, 0, amp*env))}).add;

SynthDef("grainy", {arg dens = 5, mg = 512, amp = 1, gate = 1;
	var sound, env, dur;
	dur = (Demand.ar(Impulse.ar(TRand.kr(0.0, 10.0, Dust2.kr(TRand.kr(0.0, 10.0, Dust2.kr(dens))))), 0, DNoiseRing(change: Drand([0.0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0], inf), chance: Drand([0.0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0], inf), numBits: 32))).linexp(0, 2**32, 0.01, 0.5);
	env = Linen.kr(gate, 0.01, 1, 0.05, doneAction: 0);
	sound = GrainSin.ar(2, Dust.kr(dens), dur, 100000, 0, -1, mg, 0.5);
	Out.ar(0, Pan2.ar(sound, 0, amp*env))}).add;
)

(
~brussels = Synth(\brussels, [\freq, 1, \rate, 0.1, \friction, 0.00001, \mass, 0.2, \amp, 0, \gate, 1]);
~finco = Synth(\finco, [\freq, 1, \amp, 0, \gate, 1]);
~bud = Synth(\bud, [\imp, 0, \amp, 0, \gate, 1]);
~fitz = Synth(\fitz, [\x, 8, \y, 0.0001, \amp, 0, \gate, 1]);
~gravitywang =Synth(\gravitywang, [\m, 100, \freq, 39.0265, \dens, 5, \amp, 0, \gate, 1]);
~grainy = Synth(\grainy,[\dens,5,\amp,0,\dur,1,\mg,512,\gate,1]);
)

(
MIDIdef.cc(\gravitywangCC,{arg val, num, chan;
	switch(num.postln,
		5,{~gravitywang.set(\amp,[0.01,0.5,\lin,0.1].asSpec.map(val/127)) },
)});
MIDIdef.cc(\fitzCC,{arg val, num, chan;
	switch(num.postln,
		4,{~fitz.set(\amp,[0.01,0.5,\lin,0.1].asSpec.map(val/127)) },
		21,{~fitz.set(\x,[8, 100,\exp,0.01].asSpec.map(val/127)) },
		20,{~fitz.set(\y,[0.0001, 1.0,\exp,0.000001].asSpec.map(val/127)) },
		36,{~fitz.set(\gate,[0, 1, \lin, 0.01].asSpec.map(val/127)) }
)});
MIDIdef.cc(\fincoCC,{arg val, num, chan;
	switch(num.postln,
		3,{~finco.set(\amp,[0.01,1.0,\lin,0.1].asSpec.map(val/127)) },
		19,{~finco.set(\freq,[0.01,1000.0,\lin,0.1].asSpec.map(val/127)) },
		35,{~finco.set(\gate,[0,1,\lin,0.01].asSpec.map(val/127)) }
		)});
MIDIdef.cc(\budCC,{arg val, num, chan;
	switch(num.postln,
		2,{~bud.set(\amp,[0.01,1.0,\lin,0.1].asSpec.map(val/127)) },
		18,{~bud.set(\imp,[0.0, 50.0,\lin,0.01].asSpec.map(val/127)) },
		34,{~bud.set(\gate,[0,1,\lin,0.01].asSpec.map(val/127)) }
		)});
MIDIdef.cc(\brusselsCC,{arg val, num, chan;
	switch(num.postln,
		0,{~brussels.set(\amp,[0.01,0.5,\lin,0.1].asSpec.map(val/127)) },
		1,{~brussels.set(\freq,[1, 50, \exp, 0.1].asSpec.map(val/127)) },
		17,{~brussels.set(\rate,[0.1, 1.0,\exp,0.01].asSpec.map(val/127)) },
		16,{~brussels.set(\friction,[0.00001, 0.0015,\exp,0.000001].asSpec.map(val/127)) },
		32,{~brussels.set(\gate,[0, 1, \lin, 0.01].asSpec.map(val/127)) }
)});
MIDIdef.cc(\grainyCC,{arg val, num, chan;
	switch(num.postln,
		7,{~grainy.set(\dens,[0.2,50,\lin,0.01].asSpec.map(val/127)) },
		6,{~grainy.set(\amp,\amp.asSpec.map(val/127)) },
		22,{~grainy.set(\dur,[0.01, 0.5, \lin, 0.01].asSpec.map(val/127)) },
		23,{~grainy.set(\mg,[0.01, 512.0, \lin, 0.01].asSpec.map(val/127)) },
		38,{~grainy.set(\gate,[0, 1, \lin, 0.01].asSpec.map(val/127)) }
)});
)

MIDIdef.freeAll;   // clear all MIDIdefs
