// title
<<< "Final_Bass_Player_V_S" >>>;

// use BPM class
BPM tempo;

Pan2 p => Gain g => NRev r => dac;
0.4 => g.gain;
0.01 => r.mix;

// bassline
Bass b;
b.init(p);

// notes for bassline taken from Am blues [21, 24, 26, 27, 28, 31]
[21,21, 26,27, 28,40, 43,31] @=> int bassline[];


// sequencer
int beat;
for (0 => int counter;true; counter++) {
    // beat
    counter % 8 => beat;
    Math.random2f(-1, 1) => p.pan;
    b.setpluck(Math.random2f(0.1,0.4));
    b.setnote(bassline[beat]);
    
    tempo.quarterNote => now;
}    