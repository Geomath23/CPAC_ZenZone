/////DEFINE TIME CLOCK FOR THE PATTERN
(
t = TempoClock(25/60).permanent_(true);
t.schedAbs(t.nextBar,{t.beats;1});


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//I DECLARE THE FOLDER CONTAINING THE NATURAL SOUNDSCAPE FILES (REMEMBER TO CHANGE THE FOLDER PATH TO YOUR OWN)
 (
~natural = Array.new;
~folder = PathName.new("C:/Users/gioel/Desktop/POLITECNICO MILANO/Music Engineering/CREATIVE PROGRAMMING AND COMPUTING/ZenZone - CPAC/AMBIENT NATURAL");//REMEMBER TO CHANGE THE FOLDER PATH TO YOUR OWN


~folder.entries.do({
	arg path;
	~natural = ~natural.add(Buffer.read(s,path.fullPath));// LEGGO I FILE DELLA CARTELLA E LI ALLOCO NEL SERVER
});
)
)
/////////CONTROL BUS
(
//////DRUM VOLUME
a = Bus.control;
a.set(0);
a.getSynchronous();
/////////PAD VOLUME
b = Bus.control;
b.set(0);
b.getSynchronous();

/////////PIANO VOLUME
d = Bus.control;
d.set(0);
d.getSynchronous();
/////////PIANO DELAY DRYWET
n = Bus.control;
n.set(0);
n.getSynchronous();
////////PIANO DELAY TIME
z = Bus.control;
z.set(0.3);
z.getSynchronous();
/////////PAD LOWPASS
e = Bus.control;
e.set(100);
e.getSynchronous();

////////DRUM LOWPASS
m = Bus.control;
m.set(20000);
m.getSynchronous();

)

//SYNTHDEF

//NATURE SOUNDSCAPE
(





SynthDef.new(\natural,{
	arg amp=0.7, out =0,start= 0,end, rate = 0.5,buf;
	var sig, ptr;
	ptr = Phasor.ar(0, BufRateScale.kr(buf)*rate, start, end);
	sig = BufRd.ar(2,buf,ptr);
	sig = sig*amp;
	Out.ar(out,sig);

}).add;

//PAD

 SynthDef(\padpulse, {
	arg atk = 0.3, dur = 3, rel = 0.5, crv = -2, gate = 1, amp = 0, pitch = 48,pitch2 = 60, pw1 = 0.2, tune1 = -0.006, lffreq1 = 0.01, lf1lo = 0.14, lf1hi = 0.2, tune2 = 0.006, lffreq2 = 2, lf2lo = 0.74, lf2hi = 0.8, tune3 = -12.06,ffreq = 200, mixrev = 0.5, room = 2 ;
	var env, osc1, freq1, freq2, sig, lfo1, osc2, lfo2,sus, freq3, osc3, sig2;
	sus = dur-atk;
	env = EnvGen.ar(Env.asr(atk,1,rel,crv), gate, doneAction:2);
	lfo1 = SinOsc.kr(lffreq1).range(lf1lo,lf1hi);
	lfo2 = SinOsc.kr(lffreq2).range(lf2lo,lf2hi);
	freq1 = (pitch+tune1).midicps;
	osc1 = Pulse.ar(freq1, lfo1);
	freq2 = (pitch+tune2).midicps;
	osc2 = Pulse.ar(freq2, lfo2);
	freq3 = (pitch+tune3).midicps;
	osc3 = Pulse.ar(freq3, lfo1);
	sig = Mix.ar( [osc1*0.333, osc2*0.333,osc3*0.333]);
	sig = RLPF.ar(sig,ffreq,1);
	sig = FreeVerb.ar(sig,mixrev,room);


	Out.ar([0,1],[sig]*env*amp);
}).add;

//PIANO
SynthDef(\piano, {
	arg atk = 0.01, dur = 0.5, rel = 0.3, gate = 1, amp = 0.5, pitch = 48, ffreq = 800, mixrev = 0.5, room = 2, delTime = 0.3, delDecay = 5, wet = 0.5;
	var env, piano, noiseEnv, noise, sig, delay, wetSignal, output;


	env = EnvGen.ar(Env.perc(atk, rel, amp, -4), gate, doneAction:2);
	noiseEnv = EnvGen.ar(Env.perc(atk * 0.5, rel * 0.1), gate);
	noise = WhiteNoise.ar(0.02) * noiseEnv * 0.1;
	piano = MdaPiano.ar(
		freq: pitch.midicps,
		vel: 80,
		gate: gate
	);

	sig = piano + noise;
	sig = HPF.ar(sig, 80);
	sig = FreeVerb.ar(sig, mixrev, room);
	delay = AllpassN.ar(sig, 1, delTime, delDecay);
	wetSignal = delay * wet;
	output = XFade2.ar(sig, wetSignal, wet * 2 - 1);
	Out.ar([0, 1], output * env);
}).add;


//DRUM
//KICK
SynthDef(\kick3, {
	arg out = 0,outBus = 0, effectBus,direct=0.5, amp,amptot = 0,freqfilt=20000  ;
    var snd;
    snd = DC.ar(0);
    snd = snd + (SinOsc.ar(XLine.ar(500, 60, 0.045)) * Env.perc(0.01, 0.5, curve: \lin).delay(0.005).ar(2));

    snd = snd.tanh;
	snd = snd*amp;
	snd = RLPF.ar(snd,freqfilt);
   Out.ar(out, snd*amptot);
}).add;
//HIHAT
SynthDef(\hihat, {arg out = 0,amptot = 0  , amp = 0.5, att = 0.01, rel = 0.2, ffreq = 6000, pan = 0, mixverb = 0, room = 0, outBus = 0, effectBus, direct = 0.5,freqfilt=20000;
	var env, snd;
	env = Env.perc(att, rel, amp).kr(doneAction: 2);
	snd = WhiteNoise.ar;
	snd = LPF.ar(in: snd, freq: ffreq, mul: env);
	snd = RLPF.ar(snd,freqfilt);
	Out.ar(out, snd*amptot);
}).add;
//SNARE
SynthDef(\snare, {arg out = 0, amp,amptot = 0 , sinfreq = 180, att = 0.01, rel = 0.2, ffreq = 1000, pan = 0,outBus = 0, effectBus, direct = 0.5,freqfilt=20000;
	var env, snd1, snd2, sum, i;
	i = amptot;
	env = Env.perc(att, rel, amp).kr(doneAction: 2);
	snd1 = LPF.ar(
		in: WhiteNoise.ar,
		freq: ffreq,
		mul: env
	);
	snd2 = SinOsc.ar(freq: sinfreq, mul: env);
	sum = snd1 + snd2;
	sum = RLPF.ar(sum,freqfilt);
	Out.ar(out, sum*amptot);
}).add;

)


// AUDIO GROUP

(
f = Group.new;
g = Group.new;
j = Group.new;
p = Group.new;
o = Group.new;
///////////ROUTINE FOR SELECT NATURAL SOUNDSCAPE
r = Routine.new{inf.do{arg i; ~bufn = ~natural.wrapAt(i).bufnum; 1.wait}};


// PATTERN DURATION FOR PIANO MELODY
~durations = [
    Pseq([2/4,Rest(1/8),Rest(1/8),3/4,3/4,1/4,5/4,Rest(1/4)],inf),//lenta
    Pseq([1/4,1/4,1/8,1/8,Rest(1/4),1/4,1/4,2/4],inf),//veloce
    Pseq([Rest(1/4),1/4,1/16,1/16,3/4,3/4,1/4,Rest(1.625)],inf),//lenta
     Pseq([Rest(3/8),1/8,1/16,1/16,Rest(5/8),3/8,1/4,1/8],inf),//veloce
     Pseq([Rest(1/8),Rest(1/8),3/4,2/4,Rest(1/4),Rest(1/4),3/4,5/4],inf),//lenta
Pseq([Rest(1/8),1/24,1/24,1/24,Rest(1/8),1/24,Rest(1/24),1/24],inf)//veloce
];

~currentDur = 0;

// PATTERN SCALE FOR PIANO MELODY
~scalePiano=[

//LYdia
Pseq([67, 71, 74, 76, 78, 81, 79, 74, 76, 78, 71, 69, 71, 74, 78, 67], inf),
//maggiore
Pseq([60,65,67,65,62,60,65,67,65,64,69,64,65,64,62,67],inf),
//mixolidian
Pseq([60,72,60,70,67,65,67,64,60,67,70,72,67,69,74,70],inf),
//Pseq([67,64,60,67,64,60,70,69,62,70,69,67,70,69,64,65],inf),
//dorica
Pseq([63,67,63,70,63,69,63,60,62,70,69,70,69,72,67,65],inf),
//aeolian
Pseq([60,68,65,63,60,62,60,70,72,63,67,62,63,68,70,68],inf),
//Frigia
Pseq([60,61,63,60,65,61,63,70,68,65,70,67,63,60,63,58],inf)
];
~currentScalePiano=0;

// PATTERN SCALE FOR PAD
~scalePad = [
	//lydian
	Prand([Pseq([[36,43,47,52],[42,45,36,50],[36,43,47,52],[43,47,38,54]]),Pseq([[48,55,59,64],[50,57,66,60],[40,47,55,62],[40,47,57,59]]),Pseq([[48,55,59,64],[45,52,60,59],[47,52,55,62],[45,50,66,55]])], inf),
//maggiore
Prand([Pseq([[36,43,60,52],[41,57,36,67],[36,43,59,52],[43,59,38,53]]),Pseq([[48,55,59,64],[50,57,65,60],[40,47,55,62],[40,47,57,59]]),Pseq([[48,55,59,64],[45,52,64,59],[47,52,55,62],[45,50,65,55]])], inf),
//mixolidian
Prand([Pseq([[36,43,60,52],[41,57,36,50],[36,43,58,52],[55,46,38,65]]),Pseq([[48,55,58,64],[50,57,65,60],[46,41,57,62],[50,55,58,65]]),Pseq([[48,55,58,64],[45,52,60,55],[46,53,55,62],[45,50,65,55]])], inf),
//dorica -minore
Prand([Pseq([[36,43,58,63],[41,57,36,62],[36,43,70,63],[43,46,38,53]]),Pseq([[48,55,58,63],[50,57,65,60],[46,41,57,62],[50,55,58,65]]),Pseq([[48,55,58,63],[45,51,60,55],[46,53,55,62],[45,50,65,55]])], inf),
//La minore aeoliuna
Prand([Pseq([[36,43,58,51],[41,56,36,50],[36,43,58,51],[43,58,38,53]]),Pseq([[48,55,58,63],[50,56,65,60],[46,41,56,62],[50,55,58,65]]),Pseq([[48,55,58,63],[44,51,60,55],[46,53,55,62],[44,50,65,55]])], inf),
//frigia
Prand([Pseq([[36,55,46,51],[41,56,36,49],[36,55,46,51],[60,44,37,53]]),Pseq([[48,55,58,63],[49,56,65,60],[46,39,55,60],[46,53,62,68]]),Pseq([[48,55,58,63],[44,51,60,55],[46,65,55,61],[44,49,65,55]]),Pseq([[48,55,58,63],[49,56,65,60]])], inf)
];



~currentScalePad = 0;

///PATTERN DURATIONS DRUMS

~durationsDrumsKick = [
	Prand([Rest(1/16), 1/8, Rest(1/16), 1/4,2/4], inf), //veloci
    Pseq([1/4, Rest(1/8),1/8, 1/4, Rest(1/4),1/4,1/4, Rest(1/4),1/4], inf),  //veloci
    Prand([2,1/2,1/2,1,4,1/2,1/2,1/4,1/4,1/4],inf),//lente
    Prand([2,1/2,1/2,1,4,1/2,1/2,1/4,1/4,1/4],inf)//lente
];
~durationsDrumsSnare = [
	Pseq([Rest(1/16), 1/16, 1/8, 1/16], inf), // più
	Prand([Rest(1/8), Rest(1/16), 1/8, 1/16, 1/8, 1/8, 1/16], inf),   //veloci
    Prand([Rest(1/2),Rest(1/2),Rest(1/2),Rest(1/2),Rest(1/2), 1/2, 1/2, 1/2,1/8], inf),//lente
	Prand([Rest(1/2),Rest(1/2),Rest(1/2),Rest(1/2),Rest(1/2), 1/2, 1/2, 1/2,1/8], inf),//lente
];
~durationsDrumsHihat = [
	Pseq([Rest(1/16), 1/16, 1/8, 1/16], inf), //veloci
	Prand([Rest(1/8),1/8], inf), //veloci
	Pseq([Rest(1/4), 1/4], inf),//lente
    Pseq([Rest(1/4), 1/4], inf)//lente
];
~durationsDrumsHIhat2 = [
	Prand([1/16, 1/8, 1/16, 1/4], inf),//veloci
	Prand([0.25/2,0.25/2,0.25/2,0.25/2,0.25,0.25,0.25,1,0.5,0.25,0.25,1,0.5], inf), //veloci
    Prand([0.25/2,0.25/2,0.25/2,0.25/2,0.25,0.25,0.25,1,0.5,0.25,0.25,1,0.5], inf),//lente
    Prand([0.25/2,0.25/2,0.25/2,0.25/2,0.25,0.25,0.25,1,0.5,0.25,0.25,1,0.5], inf)//lente
];
~currentDrumsKick=0;
~currentDrumsSnare=0;
~currentDrumsHihat=0;
~currentDrumsHihat2=0;


)



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//PATTERN
(

//SELECT SOUNDSCAPE
k = Synth.new(\natural,[\buf, 2,\end,~natural[0].numFrames-1  ] );


//PAD
	Pbindef(\padpat,
	\instrument, \padpulse,
		\group, g,
		\dur, Pseq([4],inf),
	\harmonic, Pexprand(1, 88,inf).round.trace,
	\pitch, Pindex(Pindex(~scalePad, Pfunc { ~currentScalePad })),

	\atk, Pwhite(1,2,inf),
	\rel, 1,
	\amp, b.asMap,
		\ffreq, e.asMap
).play(t);

//PIANO
	Pbindef(\pianopat,
	\instrument, \piano,
	\group, g,
	\dur,  Pindex(~durations, ~currentDur),
	\harmonic, Pexprand(20, 44,inf).round,
    \pitch,Pindex(~scalePiano, ~currentScalePiano),
	\atk, 0.03,
	\rel, 3,
	\amp, d.asMap,
	\wet,n.asMap,
	\delTime,z.asMap,
).play(t);



// KICK
Pbindef(\kickpat,
    \instrument, \kick3,
    \group, j,
    \out, [0, 1],
	\dur, Pindex(~durationsDrumsKick, ~currentDrumsKick),
    \att, 0.01,
    \rel, 2,
    \amp, Prand([0.4, 0.5, 0.4, 0.5], inf),
    \amptot, a.asMap,
    \freqfilt, m.asMap
).play(t);

//SNARE
Pbindef(\snarepat,
    \instrument, \snare,
    \group, p,
    \out, [0, 1],
    \dur,   Pindex(~durationsDrumsSnare, ~currentDrumsSnare),
    \att, 0.01,
    \rel, Pwhite(0.2, 0.4),
    \sinfreq, 180,
    \ffreq, 2000,
    \amp, Pwhite(0.3, 0.5),
    \amptot, a.asMap,
    \freqfilt, m.asMap
).play(t);

// HIHAT 1
Pbindef(\hihatpat,
\instrument, \hihat,
\group, o,
\out, [0, 1],
\dur,  Pindex(~durationsDrumsHihat, ~currentDrumsHihat),
\att, 0.01,
\rel, 0.5,
\ffreq, Prand([2000, 10000], inf),
\pan, 0,
\amp, Pwhite(0.1, 0.2),
\amptot, a.asMap,
\freqfilt, m.asMap
).play(t);

// HIHAT 2
Pbindef(\hihatpat2,
\instrument, \hihat,
\group, o,
\out, [0, 1],
\dur,  Pindex(~durationsDrumsHihat2, ~currentDrumsHihat2),// più note nello stesso intervallo
\att, 0.01,
\rel, 0.1,
\ffreq, Prand([100, 2000], inf),
\pan, 0,
\amp, Pwhite(0.4, 0.5),
\amptot, a.asMap,
\freqfilt, m.asMap
).play(t);




//OSC DEF FOR CONTROLL PARAMETERS IN REAL TIME

OSCdef.new(
	\nextSample,
	{
		r.next;
		k.set(\buf, ~bufn);
	},
	'/background/bottone1'
);


OSCdef.new(
	\volNature,
	{
		arg msg;
		("volNature received: " ++ msg).postln;
		k.set(\amp, msg[1].linlin(0,1,0,0.5));
	},
	'/background/fader1'
);

OSCdef.new(
	\effectNature,
	{
		arg msg;
		("effectNature received: " ++ msg).postln;
		k.set(\rate, msg[1].linlin(0,1,1,0.1));
	},
	'/background/rotary1'
);



OSCdef.new(
	\volPad,
	{
			arg msg;
		("volPad received: " ++ msg).postln;
		b.setnSynchronous([msg[1].linlin(0,1,0,0.5)]);
	},
	'/pad/fader2'
);

OSCdef.new(
	\lowpassPad,
	{
		arg msg;
		e.setnSynchronous([msg[1].linlin(0,1,100,2000)]);
	},
	'/pad/rotary1'
);


OSCdef.new(
	\volPiano,
	{
		arg msg;
		("volPiano received: " ++ msg).postln;
		d.setnSynchronous([msg[1].linlin(0,1,0,0.8)]);
	},
	'/melodia/fader1'
);


OSCdef.new(
	\wetDelay,
	{
		arg msg;
		("wetDelay received: " ++ msg).postln;
		n.setnSynchronous([msg[1].linlin(0,1,0,1)]);
	},
	'/melodia/rotary1'
);

OSCdef.new(
	\timeDelay,
	{
		arg msg;
		("timeDelay received: " ++ msg).postln;
		z.setnSynchronous([msg[1].linlin(0,1,0.3,0.8)]);
	},
	'/melodia/rotary2'
);

OSCdef.new(
	\volDrum,
	{
		arg msg;

		("volDrum received: " ++ msg).postln;
		a.setnSynchronous([msg[1].linlin(0,1,0,0.6)]);

	},
	'/drums/fader1'
);

OSCdef.new(
	\lowpassDrum,
	{
		arg msg;
		m.setnSynchronous([msg[1].linlin(0,1,20000,50)]);
	},
	'/drums/rotary1'
);

OSCdef.new(
	\melodiabottone,
	{
		arg msg;
		("PIANObottone received: " ++ msg).postln;

        // Avanza di una sequenza
        ~currentDur = (~currentDur + 1) % ~durations.size;

        // Aggiorna il pattern con la nuova sequenza di durate
        Pbindef(\pianopat, \dur, Pindex(~durations, Pfunc { ~currentDur }));

        // Opzionale: stampa la sequenza corrente per conferma
        ("Sequenza attuale: " ++ ~currentDur).postln;

	},
	'/melodia/bottone1'  // Percorso OSC
);


OSCdef.new(
    \padbottone,
    {
        arg msg;
        ("PADbottone received: " ++ msg).postln;

        // Avanza di una sequenza
        ~currentScalePad = (~currentScalePad + 1) % ~scalePad.size;
        // Avanza di una sequenza
        ~currentScalePiano = (~currentScalePiano + 1) % ~scalePiano.size;

        // Aggiorna il pattern con la nuova sequenza di durate
        Pbindef(\pianopat, \pitch, Pindex(~scalePiano, Pfunc { ~currentScalePiano }));
        // Aggiorna il pattern con la nuova sequenza di accordi
        Pbindef(\padpat, \pitch, Pindex(~scalePad, Pfunc { ~currentScalePad }));

        // Opzionale: stampa la sequenza corrente per conferma
        ("Sequenza attuale: " ++ ~currentScalePiano).postln;

    },
    '/pad/bottone1'  // Percorso OSC
);


OSCdef.new(
	\drumsbottone,
	{
		arg msg;
		("DRUMSsbottone received: " ++ msg).postln;

        // Avanza di una sequenza
        ~currentDrumsKick = ( ~currentDrumsKick + 1) % ~durationsDrumsKick.size;
		~currentDrumsSnare = ( ~currentDrumsSnare + 1) % ~durationsDrumsSnare.size;
		~currentDrumsHihat = ( ~currentDrumsHihat + 1) % ~durationsDrumsHihat.size;
		~currentDrumsHihat2 = ( ~currentDrumsHihat2 + 1) % ~durationsDrumsHihat2.size;

        // Aggiorna il pattern con la nuova sequenza di durate
        Pbindef(\kickpat, \dur, Pindex(~durationsDrumsKick, Pfunc {  ~currentDrumsKick }));
        Pbindef(\snarepat, \dur, Pindex(~durationsDrumsSnare, Pfunc {  ~currentDrumsSnare }));
		Pbindef(\hihatpat, \dur, Pindex(~durationsDrumsHihat, Pfunc {  ~currentDrumsHihat }));
		Pbindef(\hihatpat2, \dur, Pindex(~durationsDrumsHihat2, Pfunc {  ~currentDrumsHihat2 }));
        // Opzionale: stampa la sequenza corrente per conferma
        ("Sequenza attuale: " ++ ~currentDrumsKick).postln;

	},
	'/drums/bottone1'  // Percorso OSC
);

)
)
//SET IP ADDRESS AND PORT
n = NetAddr.new("192.168.1.254", 57120);
