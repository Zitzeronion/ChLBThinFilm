use Time;
use UnitTest;

config const Lx = 512, // Spatial lattice extension in X
             Ly = 512, // Spatial lattice extension in Y
             Q = 9;    // Number of lattice velocities

type my_real = real(64);            // Define types to easyly 
type my_int = int(64);

var weight = [4/9, 1/9, 1/9, 1/9, 1/9, 1/36, 1/36, 1/36, 1/36];     // Set of D2Q9 standard weights
var lattice_x = [0, 1, 0, -1, 0, 1, -1, -1, 1];                     // Set of lattice velocities in X
var lattice_y = [0, 0, 1, 0, -1, 1, 1, -1, -1];                     // Set of lattice velocities in Y

var DistSpace : domain(3) = {0..Q,1..Ly,1..Lx};     // Domain used to map the distribution functions
var FluidSpace : domain(2) = {1..Ly,1..Lx};         // Domain used to map the fluid
var BoundarySpace : domain(2) = {1..Ly,1..Lx};      // Domain used to map boundaries

var Boundaries : [BoundarySpace] bool;          // Boolean array that contains the adresses of solid boundary nodes
var Height,                                     // Array to store the height field
    Velocity_x,                                 // Array to store the velocity in X
    Velocity_y,                                 // Array to store the velocity in Y
    Pressure,                                   // Array to store the pressure  
    Forces : [FluidSpace] my_real;              // Array to add up multiple forces

var Dist_Eq,                                    // Array to store the equilibrium distribution function, see e.g. Salom LBM shallow water paper 
    Dist_Tmp,                                   // Array to store the distribution function from the previous time step, important for tau != 1
    Dist_Out : [DistSpace] my_real;             // Array to store the distribution which is computed 

/*
First procedure to test IO and stuff
*/
proc Hello
{
    var String_hello = "Hello world!";      // Yes a var can be anything, int, real, complex, string ...
    writeln(String_hello);
}

/*
Calculating the product u_i*u_i, such (u_x, u_y)*(u_x, u_y) for every lattice node
*/
proc Dot_prod(ref u:real, ref v:real) : real
{
    var x: real;        // Store the calculated value
    x += u*u + v*v;      // Performe the calculation
    return x;
}

/*
Tests for Dot_prod
*/
proc test_Dot_prod_simple(test: borrowed Test) throws
{
    var A = [1.0, 1.0];
    var B = [1.0, 2.0];
    var C = [2.0, 5.0];
    test.assertTrue(Dot_prod(A, B) == C);
} 
proc test_Dot_prod_zeros(test: borrowed Test) throws
{
    var A = [0.0, 0.0];
    test.assertTrue(Dot_prod(A, A) == A);
} 

/*
Procedure for calculating the equilibrium distriubtion
*/
// proc deriveEquilibrium(ref elevation: real, ref vel_x: real, ref vel_y: real, lat_x: int, lat_y: int, weight: real, gravity: real)
// {
//     var f :[0..9,1..Ly,1..Lx] real;
//     for i in {1..9}{
//         writeln("blub");
//     }
// }

// proc main
// {
//     Hello;
//     writeln("Boundary space default values: ", Boundaries(3,3), "\n others: " , Height(2,1), " ", Dist_Eq(1,2,1) );   
//     var A = [1.1, 2.2, 3.3];
//     var B = [1.0, 0.0, 1.0];
//     var C = Dot_prod(A, B);
//     writeln(C);
// }

//UnitTest.main();