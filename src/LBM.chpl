use Time, IO.FormattedIO;
use UnitTest;

config const Lx = 512,          // Spatial lattice extension in X
             Ly = 512,          // Spatial lattice extension in Y
             Q = 9;             // Number of lattice velocities
             //gravity = 0.1;     // Value of gravitational forcing

var DistSpace : domain(3) = {0..Q,1..Ly,1..Lx};     // Domain used to map the distribution functions
var FluidSpace : domain(2) = {1..Ly,1..Lx};         // Domain used to map the fluid
var BoundarySpace : domain(2) = {1..Ly,1..Lx};      // Domain used to map boundaries

var Boundaries : [BoundarySpace] bool;          // Boolean array that contains the adresses of solid boundary nodes
var Height,                                     // Array to store the height field
    Velocity_x,                                 // Array to store the velocity in X
    Velocity_y,                                 // Array to store the velocity in Y
    Pressure,                                   // Array to store the pressure  
    Forces : [FluidSpace] real;              // Array to add up multiple forces

var Dist_Eq,                                    // Array to store the equilibrium distribution function, see e.g. Salom LBM shallow water paper 
    Dist_Tmp,                                   // Array to store the distribution function from the previous time step, important for tau != 1
    Dist_Out : [DistSpace] real;             // Array to store the distribution which is computed 

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

/*
Procedure for calculating the equilibrium distriubtion
*/
proc deriveEquilibrium(Elevation, Vel_x, Vel_y: [?D] real, gravity : real, X, Y: int)
{
    var Dist_f : [1..Q,1..Y,1..X] real;
    var Weight = [4.0/9.0, 1.0/9.0, 1.0/9.0, 1.0/9.0, 1.0/9.0, 1.0/36.0, 1.0/36.0, 1.0/36.0, 1.0/36.0];     // Set of D2Q9 standard weights
    var Lattice_vel_x = [0, 1, 0, -1, 0, 1, -1, -1, 1];                                         // Set of lattice velocities in X
    var Lattice_vel_y = [0, 0, 1, 0, -1, 1, 1, -1, -1];                                         // Set of lattice velocities in Y
    Dist_f = 1.0;
    forall (y_i,x_i) in D               // Do it for the zeroth lattice velocity
    {
        Dist_f(1,y_i,x_i) = Weight(1) * Elevation(y_i,x_i) * (9.0/4.0 - 15.0/8.0 * gravity * Elevation(y_i,x_i) 
                                                             - 3.0/2.0 * Dot_prod(Vel_x(y_i,x_i),Vel_y(y_i,x_i)));
    }
    forall (q_i,y_i,x_i) in {2..9,1..Y,1..X} // And for the remaining 8 lattice velocities
    {
        Dist_f(q_i,y_i,x_i) = Weight(q_i) * Elevation(y_i,x_i) * (3.0/2.0 * gravity * Elevation(y_i,x_i) 
                                                                  + 3.0 * (Lattice_vel_x(q_i) * Vel_x(y_i,x_i) + Lattice_vel_y(q_i) * Vel_y(y_i,x_i))
                                                                  + 9.0/2.0 * (Lattice_vel_x(q_i) * Vel_x(y_i,x_i)) * (Lattice_vel_y(q_i) * Vel_y(y_i,x_i))
                                                                  - 3.0/2.0 * Dot_prod(Vel_x(y_i,x_i),Vel_y(y_i,x_i))); 
    }
    
    return Dist_f;
}
proc test_Eq_dist_nogravity_novelocity(test: borrowed Test) throws
{
    var L = 4;                                      // Create a small test area
    var g = 0.0;                                    // Test without gravity
    var check_eq : [1..Q,1..L,1..L] real;           // Generate an array similar to f_eq
    var h,                                          // h = height field
        u : [1..L,1..L] real;                       // u = velocity field
    h(2,1) = 1.0;                                   // Set only one value different to test it!
    check_eq = deriveEquilibrium(h,u,u,g,L,L);      // Calculate the equilibrium without gravity and velocity  
    test.assertTrue(check_eq[1,1..L,1..L] == h);    // Test it
}
proc test_Eq_dist_basic(test: borrowed Test) throws
{
    var L = 4;                                      // Create a small test area
    var g = 6.0/50;                                 // Test without gravity
    var check_eq,
        answer : [1..Q,1..L,1..L] real;           // Generate an array similar to f_eq
    var h,                                          // h = height field
        u : [1..L,1..L] real;                  // analytical solution     
    h(2,1) = 1.0;                                   // Set only one value different to test it!
    answer(1,2,1) = 0.9;
    for i in 2..5 do
        answer(i,2,1) = 1.0/50.0;
    for i in 6..Q do
        answer(i,2,1) = 1.0/200.0;
    check_eq = deriveEquilibrium(h,u,u,g,L,L);          // Calculate the equilibrium without gravity and velocity 
    writeln("For g != 0 we get \n", check_eq);
    test.assertLessThan(check_eq,answer);               // Test it
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