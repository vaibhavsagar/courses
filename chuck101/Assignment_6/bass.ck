// title
<<< "Assignment_6_Bass_V_S" >>>;

// 8ths are the smallest unit of time
.3125::second => dur eighth;

Gain g => NRev r => dac;
0.3 => g.gain;
0.2 => r.mix;

// bassline
TriOsc bass => Pan2 p => g; 
Mandolin b => p;

// notes for bassline taken from [22, 24, 25, 27, 29, 30, 32, 34]
[22,22,22,22, 24,25,27,25, 30,29,30,32, 30,29,27,29] @=> int bassline[];

// sequencer
int beat;
for (0 => int counter; counter < 96; counter++) {
    // beat
    counter % 16 => beat;
    Math.random2f(-1, 1) => p.pan;
    Math.random2f(0.1,0.4) => b.pluck;
    Std.mtof(bassline[beat]) => b.freq;
    Std.mtof(bassline[beat]) => bass.freq;
    eighth => now;
}    