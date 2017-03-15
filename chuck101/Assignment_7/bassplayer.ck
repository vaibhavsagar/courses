// title
<<< "Assignment_7_Bass_V_S" >>>;

// 8ths are the smallest unit of time
.3125::second => dur eighth;

Pan2 p => Gain g => NRev r => dac;
0.3 => g.gain;
0.2 => r.mix;

// bassline
Bass b;
b.init(p);

// notes for bassline taken from [22, 24, 25, 27, 29, 30, 32, 34]
[24,24,24,24, 29,28,28,26, 31,33,35,31, 29,29,28,29] @=> int bassline[];


// sequencer
int beat;
for (0 => int counter; counter < 96; counter++) {
    // beat
    counter % 16 => beat;
    Math.random2f(-1, 1) => p.pan;
    b.setpluck(Math.random2f(0.1,0.4));
    b.setnote(bassline[beat]);
    
    eighth => now;
}    