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
Below are UnitTests, one for a simple case, the other one if the velocities are zeros
*/
proc Dot_prod(ref u:real, ref v:real) : real
{
    var x: real;        // Store the calculated value
    x = u*u + v*v;      // Performe the calculation
    return x;
}
proc test_Dot_prod_simple(test: borrowed Test) throws
{
    var A = [1.0, 1.0];
    var B = [1.0, 2.0];
    var C = [2.0, 5.0];                         // Because 1*1 + 1*1 = 2 and 1*1 + 2*2 = 5 right?
    test.assertTrue(Dot_prod(A, B) == C);       // If not, you broke it, so fix it!
} 
proc test_Dot_prod_zeros(test: borrowed Test) throws
{
    var A = [0.0, 0.0];                         // Same story, the zero vector should always generate the zero vector
    test.assertTrue(Dot_prod(A, A) == A);       // Works fine
} 

//############################################ Code good up tpo here ############################################//
// Gona fix that tomorrow....
// Good night for today!
/*
Procedure for calculating the equilibrium distriubtion
*/
proc deriveEquilibrium(elevation, vel_x, vel_y: [?D] real, X, Y: int)
{
    var f : [1..3,1..Y,1..X] real; 
    var gravity = 0.0;
    forall (i,j) in D
    {
        f[1,i,j] = 4/9 * elevation[i,j] * (9/4 - 15/8 * gravity * elevation[i,j] - 3/2 * Dot_prod(vel_x[i,j], vel_y[i,j]));
    }
    writeln("Feq by proc: \n", f);
    return f;
}
proc test_Eq_dist_basic(test: borrowed Test) throws
{
    var L = 4;
    var h,
        u : [1..L,1..L] real;
    h = 1.0;
    writeln("Print h: \n", h, "\n");
    writeln("Print feq: \n",deriveEquilibrium(h,u,u,L,L), "\n");
    test.assertTrue(deriveEquilibrium(h,u,u,L,L) == h);
}

// proc main
// {
//     Hello;
//     writeln("Boundary space default values: ", Boundaries(3,3), "\n others: " , Height(2,1), " ", Dist_Eq(1,2,1) );   
//     var A = [1.1, 2.2, 3.3];
//     var B = [1.0, 0.0, 1.0];
//     var C = Dot_prod(A, B);
//     writeln(C);
// }

UnitTest.main();