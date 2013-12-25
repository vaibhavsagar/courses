// title
<<< "Assignment_2_V_S" >>>;
// sound network for lead
TriOsc s => Pan2 p => dac;
// bass
SinOsc b => dac;
0.4 => b.gain;
// MIDI notes, D Dorian scale
[50, 52, 53, 55, 57, 59, 60, 62] @=> int notes[];
// quarter note
.25::second => dur quarter;
Math.srandom(219); // same thing every time
for (120 => int i; i>0; i--) {
    // pick a random note to play
    Math.random2(0, notes.cap()-1) => int note;
    // choose octave
    Math.random2(-3, 3) => int octave;
    // change gain based on octave
    if (octave<1) {
        .6 => s.gain;
    } else {
        .4 => s.gain;
    }
    // random panning for lead, bass panning does not change
    Math.random2f(-1, 1) => p.pan;
    // lead plays the note
    Std.mtof(notes[note]+(12*octave)) => s.freq;
    // simple bassline
    Std.mtof(notes[note] - 12) => b.freq;
    // advance time by a quarter note
    quarter => now;
}