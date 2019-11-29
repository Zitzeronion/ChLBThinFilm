use BlockDist, CyclicDist, Time;

config const Lx = 512, // Spatial lattice extension in X
             Ly = 512, // Spatial lattice extension in Y
             Q = 9;    // Number of lattice velocities

var DistSpace : domain(3) = {0..Q,1..Ly,1..Lx};     // Domain used to map the distribution functions
var FluidSpace : domain(2) = {1..Ly,1..Lx};         // Domain used to map the fluid
var BoundarySpace : domain(2) = {1..Ly,1..Lx};      // Domain used to map boundaries

var Boundaries : [BoundarySpace] bool;      // Boolean array that contains the adresses of solid boundary nodes
var Height,                                 // Array to store the height field
    Velocity_x,                             // Array to store the velocity in X
    Velocity_y,                             // Array to store the velocity in Y
    Pressure,                               // Array to store the pressure  
    Forces : [FluidSpace] real;             // Array to add up multiple forces

var Dist_Eq,
    Dist_Tmp,
    Dist_Out : [DistSpace] real;

proc Hello
{
    writeln("Hello world!");
}

proc main
{
    Hello;
    writeln("Boundary space default values: ", Boundaries(3,3), "\n others: " , Height(2,1), " ", Dist_Eq(1,2,1) );
}