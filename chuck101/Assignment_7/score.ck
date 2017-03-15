// score.ck
<<< "Assignment_7_Initialise_V_S" >>>;
// tempo
BPM tempo;
tempo.tempo(96.0);

// Add your composition files when you want them to come in

Machine.add(me.dir() + "/drums.ck") => int drumID;

8.0 * tempo.quarterNote => now;

Machine.add(me.dir() + "/bassplayer.ck") => int bassID;
40.0 * tempo.quarterNote => now;
Machine.remove(drumID);
Machine.remove(bassID);