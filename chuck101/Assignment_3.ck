// title
<<< "Assignment_3_V_S" >>>;

// sound chain

Gain g => dac;
0.5 => g.gain;

// I decided it sounded better without a lead, but you can add it back in if you want
//SawOsc lead  =>  Pan2 p =>  g; // random
//.3 => lead.gain;
TriOsc bass => Pan2 p => g; // bassline
.75 => bass.gain;

SndBuf kicka => g; // kick_03 for attack
0.75 => kicka.gain;
SndBuf kickb => g; // kick_02 for body
0.75 => kickb.gain;
SndBuf snare => g; // snare_03
0.5 => snare.gain;
SndBuf hihat => g; // hihat_02
0.5 => hihat.gain;
SndBuf clap  => g; // clap_01
0.3 => clap.gain;

// 8ths are the smallest unit of time
.125::second => dur eighth;

Math.srandom(219); // same thing every time

// load files
me.dir() + "/audio/" => string path;
["kick_03.wav","kick_02.wav","snare_03.wav","hihat_02.wav","clap_01.wav"] @=> string files[];
[kicka,kickb,snare,hihat,clap] @=> SndBuf bufs[];
for (0 => int i; i<files.cap(); i++) {
    path + files[i] => bufs[i].read; // load file into buffer
    bufs[i].samples() => bufs[i].pos; // playhead set to end
}

// no pattern for hi hat as that occurs on every beat
[1,0,0,0 ,1,0,1,0 ,1,0,1,0 ,1,0,0,0] @=> int  kick_pattern[]; // kick pattern
[0,0,1,0 ,0,0,0,0 ,0,0,1,0 ,0,0,0,0] @=> int snare_pattern[]; // snare pattern

// notes for bassline taken from [26, 28, 29, 31, 33, 35, 36, 38]
[26,26,26,26, 28,29,29,29, 35,33,33,33, 31,31,33,31] @=> int bassline[];
 
// notes for randomly generated lead
[50, 52, 53, 55, 57, 59, 60, 62] @=> int lead_notes[];



// sequencer
int beat;
for (0 => int counter; counter < 240; counter++) {
    // beat
    counter % 16 => beat;
    
    // kick setup
    if (kick_pattern[beat] == 1) {
        0 => kicka.pos;
        0 => kickb.pos;
    } else {
        kicka.samples() => kicka.pos;
        kickb.samples() => kickb.pos;
    }
    
    // snare setup
    if (snare_pattern[beat] == 1) {
        0 => snare.pos;
        0 => clap.pos;
    } else {
        snare.samples() => snare.pos;
        clap.samples()  => clap.pos;
    }
    
    // hihat rate setup
    Math.random2f(-2, 2) => hihat.rate;
    if (hihat.rate()<0) {
        hihat.samples() => hihat.pos;
    } else {
        0 => hihat.pos;
    }
    
    // bass
    Math.random2f(-1, 1) => p.pan;
    Std.mtof(bassline[beat]) => bass.freq;
    
    //Math.random2f(-1, 1) => p.pan;
    //Std.mtof(lead_notes[Math.random2(0, lead_notes.cap()-1)]) => lead.freq;
    
    // advance time
    eighth => now;
    for (0 => int i; i<files.cap(); i++) {
        bufs[i].samples() => bufs[i].pos; // playhead set to end
    }
    
}