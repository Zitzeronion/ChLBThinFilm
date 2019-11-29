use BlockDist, CyclicDist, Time;

config const Lx = 512,
             Ly = 512,
             Q = 9;

var FluidSpace : domain(2) = {1..Ly, 1..Lx};
var BoundarySpace : domain(2) = {1..Ly,1..Lx};

proc Hello
{
    writeln("Hello world!");
}

proc main
{
    Hello;
}