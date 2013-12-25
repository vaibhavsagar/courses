// title
<<< "Assignment_4_V_S" >>>;

// set playhead to end
fun void end(SndBuf sound) {
    sound.samples() => sound.pos;
}

// connect SndBuf to Gain and scale volume.
fun void init(SndBuf sound, float vol, Gain gain) {
    sound => gain;
    vol => sound.gain;
}

// set playhead depending on pattern
fun void setup(SndBuf sound, int i) {
    if (i==1) {
        0 => sound.pos;
    } else {
        end(sound);
    }
}

// sound chain

Gain g => dac;
0.5 => g.gain;

TriOsc bass => Pan2 p => g; // bassline

SndBuf kicka, kickb, snare, hihat, clap;

// 8ths are the smallest unit of time
.3::second => dur eighth;

Math.srandom(219); // same thing every time

// load files
me.dir() + "/audio/" => string path;
["kick_03.wav","kick_02.wav","snare_03.wav","hihat_02.wav","clap_01.wav"] @=> string files[];
[kicka,kickb,snare,hihat,clap] @=> SndBuf bufs[];
[0.75, 0.75, 0.5,  0.5,  0.3]  @=> float  vols[];
for (0 => int i; i<files.cap(); i++) {
    path + files[i] => bufs[i].read; // load file into buffer
    init(bufs[i], vols[i], g);
    end(bufs[i]);
}

// no pattern for hi hat as that occurs on every beat
[1,0,0,0 ,1,0,0,0 ,1,0,1,0 ,1,0,0,0] @=> int  kick_pattern[]; // kick pattern
[0,0,0,0 ,1,0,0,0 ,0,0,0,0 ,1,0,0,0] @=> int snare_pattern[]; // snare pattern

// notes for bassline taken from [27, 29, 31, 32, 34, 36, 37, 39]
[27,27,27,27, 29,31,31,32, 37,36,34,34, 32,32,34,31] @=> int bassline[];


// sequencer
int beat;
for (0 => int counter; counter < 100; counter++) {
    // beat
    counter % 16 => beat;
    
    // kick setup
    setup(kicka, kick_pattern[beat]);
    setup(kickb, kick_pattern[beat]);
    
    // snare setup
    setup(snare, snare_pattern[beat]);
    setup(clap,  snare_pattern[beat]);
    
    // hihat rate setup
    Math.random2f(-3, 3) => hihat.rate;
    if (hihat.rate()<0) {
       end(hihat);
    } else {
        0 => hihat.pos;
    }
    
    // bass
    Math.random2f(-1, 1) => p.pan;
    Std.mtof(bassline[beat]) => bass.freq;
    
    // advance time
    eighth => now;
}