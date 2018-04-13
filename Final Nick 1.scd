// For the final project, I will be improvising with a set of very different sounding synths that are controlling very different looking shapes on Jitter. I will have a set of 10-16 synthdefs that I will control with a nanopad and a nanokontrol. The synthdefs will send osc to manipulate the shapes in jitter. I’ll probably be performing from the mixing booth and I’ll use the front two house speakers. It will probably be around 5 minutes long.


MIDIIn.connectAll

(
~whitOut = NetAddr("127.0.0.1", 48155);

SynthDef(\whit,{|amp=0.4, freqw=1.0, length=1.0, gate=1, www=1.0|
	var modulator, carrier, filt, pan, level, trig;
	modulator = Mix(SinOsc.ar(freqw*[200, 500, 900, 700], 0, 1).abs);
	carrier = Mix(SinOsc.ar(www*[200*modulator, 300*modulator, 500*modulator]), 0, 1);
	filt = RHPF.ar(freqw*carrier*Crackle.ar(2)*EnvGen.kr(Env.asr(0.5, 0.5, 0.3), gate, doneAction:2));
	pan = Pan2.ar(filt, ClipNoise.ar(www+0.1)*0.5*SinOsc.ar(www*10+0.1, 0, 5).poll(4,"dust"));
	level = 100*Amplitude.kr(pan);
	trig = SendTrig.kr(SinOsc.kr(400), 1, level);
	Out.ar(0,pan*amp);
}).add;

p = OSCFunc({ arg msg, time;
    [time, msg].postln;
	~whitout.sendMsg("/level", msg[3]);
},'/tr', s.addr);
)

(
SynthDef(\woo,{|amp=0.5, freq=700.0, gate=1|
	var jj, pan;
	jj = PinkNoise.ar(0.5)*EnvGen.kr(Env.perc(0.00,0.05))+SinOsc.ar(500)*SinOsc.ar(freq)*EnvGen.kr(Env.asr(1.0, 0.2, 1.0), gate, doneAction:2);
	pan = Pan2.ar(jj, -0.3);
	Out.ar(0, pan*amp*0.5);
}).add;
)


(
~www = 1.0;
~whitOut2 = NetAddr("127.0.0.1", 48156);
~synths = Array.fill(128,{nil});
MIDIdef.noteOn(\testOn,{ arg vel,note;
		if (note == 52, {~synths.put(52,Synth(\whit,[\amp,vel/127,\www,~www]))});
	    if (note == 53, {~synths.put(53,Synth(\woo,[\amp,vel/127]))});
},nil,0).fix(true);

MIDIdef.noteOff(\testOff,{ arg vel,note;
if(~synths[note].notNil,{ ~synths[note].release; ~synths.put(note,nil) })
},nil,0).fix(true);

MIDIdef.cc(\testCC,{ arg val, num, chan;  // this is the vector for controller events
	var synthsOn;
	switch(num.postln,	// save cmratios and indexes
	0,{ ~www=([0.1,20,\lin,0.1].asSpec.map(val/100)) },
	0,{ ~whitOut2.sendMsg("/level", val)},
	)}).fix(true);
)


52,{ ~	switch(note.postln,
	synths.put(52,Synth(\whit,[\amp,vel/127,\www,~www]))});

MIDIdef.freeAll;