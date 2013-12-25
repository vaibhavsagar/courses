// score.ck
<<< "Assignment_6_Initialise_V_S" >>>;

// Add your composition files when you want them to come in
<<< me.dir() >>>;
Machine.add(me.dir() + "/drums.ck") => int drumID;

5::second => now;

Machine.add(me.dir() + "/bass.ck") => int bassID;
25::second => now;
Machine.remove(drumID);
Machine.remove(bassID);