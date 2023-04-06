/*********************************************
 * OPL 12.9.0.0 Model
 * Author: iefcyang
 * Creation Date: Mar 31, 2023 at 6:02:22 PM
 *********************************************/
dvar float+ x1;
dvar float+ x2;

maximize 5 * x1 + 4 * x2;
subject to
{
6 * x1 + 4 * x2 <=24;
x1+2*x2<=6;
-x1+x2<=1;
x2<=2;
}