// title
<<< "Final_Melody_V_S" >>>;

// use BPM class
BPM tempo;

SinOsc s => NRev r => Pan2 p => dac;
0.1 => s.gain;

// notes for bassline taken from Am blues [57, 60, 62, 63, 64, 67]
[57,60,57,62, 64,63,62,63, 62,64,67,64, 64,63,62,57] @=> int lead[];


// sequencer
int beat;
for (0 => int counter;true; counter++) {
    // beat
    counter % 16 => beat;
    Math.random2f(-1, 1) => p.pan;
    Std.mtof(lead[beat]) => s.freq;
    
    tempo.eighthNote => now;
}    