// initialise.ck
<<< "Assignment_7_Initialise_V_S" >>>;

// same thing every time
Math.srandom(219); 

// add BPM and Bass class
Machine.add(me.dir()+"/BPM.ck");
Machine.add(me.dir()+"/bass.ck");

// Add score file
<<< me.dir() + "/score.ck" >>>;
Machine.add(me.dir() + "/score.ck");