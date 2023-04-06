/*********************************************
 * OPL 12.9.0.0 Model
 * Author: iefcyang
 * Creation Date: Mar 31, 2023 at 5:36:10 PM
 *********************************************/

int n = ...; // number of cities
range cities = 1..n;

// distance matrix
float dist[cities][cities] = ...; 

// decision variables
dvar boolean x[cities][cities]; // edge inclusion variables
dvar float+ u[cities]; // visitation order variables

// objective function
minimize
  sum(i in cities, j in cities: i!=j) dist[i][j] * x[i][j];

// constraints
subject to {
  // each city must be visited exactly once
  forall(i in cities)
    sum(j in cities: j!=i) x[i][j] == 1;
  
  // each city must be left exactly once
  forall(j in cities)
    sum(i in cities: i!=j) x[i][j] == 1;

  // subtour elimination constraints
 
   forall( i,j in 2..n: i != j ) u[i] - u[j] + n*x[i][j] <= n-1;
  
//  forall(i in cities: i!=1, j in cities: j!=1, i!=j ) 
 // u[i] - u[j] + n*x[i][j] <= n-1;

  // binary constraints
 // forall(i in cities, j in cities)
//    x[i][j] in {0,1};

  // symmetry-breaking constraints
  u[1] == 1;
  forall(i in cities: i!=1)
    u[i] >= 2;
}

