// score.ck
<<< "Final_Initialise_V_S" >>>;
// tempo
BPM tempo;
tempo.tempo(125.0);

// Add your composition files when you want them to come in

Machine.add(me.dir() + "/drums.ck") => int drumID;

8.0 * tempo.quarterNote => now;

Machine.add(me.dir() + "/bassplayer.ck") => int bassID;
Machine.add(me.dir() + "/melody.ck") => int melID;
117.0 * tempo.quarterNote => now;
Machine.remove(drumID);
Machine.remove(bassID);
Machine.remove(melID);