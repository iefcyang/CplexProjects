/*********************************************
 * OPL 12.9.0.0 Model
 * Author: iefcyang
 * Creation Date: Mar 31, 2023 at 9:40:34 AM
 *********************************************/
int numberOfProducts = ...;
range products = 1..numberOfProducts;

int numberOfPods = ...;
range pods = 1..numberOfPods;

int L = ...; // layer capacity in a pod
int B = ...; // product Type Limit in a pod

float s[products, products ] = ...;
int D[products ] = ...;
 
dvar boolean x[products, pods]; // a product is placed on a pod
dvar boolean X[products,products,pods];
dvar int+ y[products,pods]; // number of layers occupied by a product in a pod

maximize 
	sum( i in products, j in i+1..numberOfProducts, m in pods ) s[i,j]* X[i,j,m]; // x[i,m]*x[j,m] ;
	
subject to
{
	//(1) The sum of the layers of products assigned to a pod 
	forall( m in pods )
	   sum( i in products) y[i,m] == L;
	
	//(2) The sum of layers assigned to pods of a type meet the initial demands
	forall( i in products )
	   sum( m in pods ) y[i,m] == D[i]; 
   
    //(3) The sum of product types in a pod is restricted
    forall( m in pods )
       sum( i in products ) x[i,m] <= B;
    
    //(4) 
    forall( i in products, m in pods)
      	y[i,m] <= L * x[i,m];
      	
    //(5) 	      	      	
    forall( i in products, m in pods)
       x[i,m] <= y[i,m];
	
	// Restriction of three planes to round; // alternative is simple using two plans
	// (x[i,m],x[j,m],X[i,j,m]) {(0,0,0),(1,0,0),(0,1,0),(1,1,1)}
	forall( i in products, j in products, m in pods )
	   X[i,j,m] <= x[i,m];
	   
	forall( i in products, j in products, m in pods )
	   X[i,j,m] <= x[j,m];	   
	   
	forall( i in products, j in products, m in pods )
	   X[i,j,m] >= x[i,m] + x[j,m] - 1;	
	   
	   
}

	
   
