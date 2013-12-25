// title
<<< "Final_Drums_V_S" >>>;

// Reimplemented sequencer with concurrency

// sound chain

Gain g => dac;
0.5 => g.gain;

SndBuf kicka, kickb, snare, hihat, clap;
BPM tempo;

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

// play pattern with array of drum sounds
fun void drums(int pattern[], SndBuf snds[]) {
    for(0 => int counter; true ; counter++) {
        counter % 16 => int beat;
        // kick setup
        for (0 => int i; i<snds.cap(); i++){
            setup(snds[i], pattern[beat]);
        }
        tempo.eighthNote => now;
    }
}

// special function for hihats

fun void hihats() {
    for (0 => int counter; true; counter++) {
        counter % 16 => int beat;
        Math.random2(-1, 1) => hihat.rate;
        if (hihat.rate()<0) {
        end(hihat);
        } else {
            0 => hihat.pos;
        }
        tempo.eighthNote => now;
    }
}

// load files
me.dir(-1) + "/audio/" => string path;
["kick_03.wav","kick_02.wav","snare_03.wav","hihat_02.wav","clap_01.wav"] @=> string files[];
[kicka,kickb,snare,hihat,clap] @=> SndBuf bufs[];
[0.75, 0.75, 0.4,  0.4,  0.25]  @=> float  vols[];
for (0 => int i; i<files.cap(); i++) {
    path + files[i] => bufs[i].read; // load file into buffer
    init(bufs[i], vols[i], g);
    end(bufs[i]);
}

// no pattern for hi hat as that occurs on every beat

[1,0,0,0 ,1,0,0,0 ,1,0,0,0 ,1,0,0,0] @=> int kick_pattern[]; // kick pattern
[0,0,0,0 ,1,0,0,0 ,0,0,0,0 ,1,0,0,0] @=> int snare_pattern[]; // snare pattern

// sequencer
spork ~ drums(kick_pattern, [kicka, kickb]);
8*tempo.quarterNote => now;
spork ~ drums(snare_pattern, [snare, clap]);
4*tempo.quarterNote => now;
spork ~ hihats();
100*tempo.quarterNote => now;