// title
<<< "Assignment_1_V_S" >>>;
// sound network
TriOsc s => dac;
// volume
.4 => s.gain;
// for looping
120 => int i;
float f;
while (i > 0) {
    // picking a frequency between A1 and A3
    Math.random2(55, 440) => f;
    f => s.freq;
    // reduce gain for higher notes
    if (f > 220) {
        .2 => s.gain;
    } else {
        // reset gain
        .4 => s.gain;
    }
    // advance time by 0.25 seconds
    .25::second => now;
    i - 1 => i;
}