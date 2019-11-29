use BlockDist, CyclicDist, Time;

config const Lx = 512, // Spatial lattice extension in X
             Ly = 512, // Spatial lattice extension in Y
             Q = 9;    // Number of lattice velocities

var DistSpace : domain(3) = {0..Q,1..Ly,1..Lx};     // Domain used to map the distribution functions
var FluidSpace : domain(2) = {1..Ly,1..Lx};         // Domain used to map the fluid
var BoundarySpace : domain(2) = {1..Ly,1..Lx};      // Domain used to map boundaries


proc Hello
{
    writeln("Hello world!");
}

proc main
{
    Hello;
}