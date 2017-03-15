// bass.ck
// Let there be bass

public class Bass {
    TriOsc   bass1; 
    Mandolin bass2;
    
    fun void init (Pan2 pan) {
        bass1 => pan;
        bass2 => pan;
    }
    fun void setnote( int note) {
        Std.mtof(note) => bass1.freq;
        Std.mtof(note) => bass2.freq;
    }
    
    fun void setpluck(float pluck) {
        pluck => bass2.pluck;
    }

}