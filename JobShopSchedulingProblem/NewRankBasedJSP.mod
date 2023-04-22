 
//nbJobs = 6;
//nbMchs = 6;
//
//Ops = [
// [ <5,4>, <1,3>, <4,3>, <3,2>, <0,1>, <2,2> ],
// [ <1,3>, <0,8>, <5,7>, <2,2>, <4,9>, <3,3> ],
// [ <3,1>, <4,9>, <1,9>, <0,7>, <5,5>, <2,5> ],
// [ <3,8>, <4,2>, <1,1>, <5,7>, <2,8>, <0,9> ],
// [ <1,6>, <3,2>, <4,5>, <5,5>, <0,3>, <2,1> ],
// [ <4,10>, <2,4>, <0,4>, <3,3>, <1,2>, <5,3> ]
//];
 
 
// Required data structure to read in dat file
tuple machineIDandTime
{
   int mID;
   int time;
};


// Read in data
int nbJobs = ...;
int nbMchs = ...;
int lastID = nbMchs-1;

range jobs = 0..nbJobs-1;
range machines = 0..nbMchs-1;

machineIDandTime Ops[jobs,machines] = ...;

range ranks = 0..nbJobs-1;


// P[i,j]: The processing time of the operation of job j on machine i
int P[i in machines, j in jobs ] = max( s in machines : Ops[j,s].mID == i ) Ops[j,s].time;

// r[i,j,p]: If the s-th operation of job j is on machine i
int r[i in machines, j in jobs, s in machines] = Ops[j,s].mID == i ? 1:0;

dvar int+ Cmax;  // Makespan

// r[i,k]: The start time of the k-th operation processed on machine i.
dvar int+ h[machines,ranks];

// x[i,j,k]: The operation of job j is the k-th operated on machine i. 
dvar boolean x[machines, jobs, ranks];  
dvar boolean y[machines, jobs, machines];

//dexpr int z[ j in jobs,  k in machines, l in machines ] = sum(i in machines )r[i,j,l]*x[i,j,k]; // sum(i in machines, k in ranks )r[i,j,l]*x[i,j,k]

int V = 10000;

 
 minimize Cmax;
 
 subject to
 {
   
    // On each machine, each rank is assigned to one job;
    // Loop through all jobs on a machine with a rank, only one 1 is given
    forall( i in machines, k in ranks ) 
    	sum( j in jobs ) x[i,j,k] == 1;
    
    // For a job only one rank k is assigned on a machine to process its operation
    forall( i in machines, j in jobs ) 
    	sum( k in ranks ) x[i,j,k] == 1;
    	
    // On a machine, the start time of the (k)-th processed opeation must be greater
    // than the completion time of the (k-1)-th one. 
    forall( i in machines, k in 1 .. nbJobs-1)
        h[i,k-1] + sum( j in jobs ) P[i,j] * x[i,j,k-1] <= h[i,k];
        
    // Makespan always greater than the completion time of the last processed operation on each machine
    forall( i in machines )
       h[i,nbJobs-1] + sum( j in jobs ) P[i,j]*x[i,j,nbJobs-1] <= Cmax;
       

// The start time of l-th operation of jbo j evaluated from sum over r must check for the fact that
// the operation is decided to processed in the k-th order 
// sum(i in machines )r[i,j,l]*x[i,j,k] is 1 if l-th operation of job j is to be processed on the k-order
    forall( j in jobs, l in 0..nbMchs-2 )   
    	sum( i in machines )r[i,j,l]*y[i,j,l] + sum( i in machines)r[i,j,l]*P[i,j] <=
    		V * ( 1 - sum(i in machines )r[i,j,l]*x[i,j,k]	) +
    		V * ( 1 - sum( i in machines )r[i,j,l+1]*x[i,j,kp] ) +
    		sum( i in machines ) r[i,j,l+1]*h[i,kp];	   
  
 // l-th start time of job j must be larger than end time of the (l-1)th   Ops[j,l].mID Ops[j,l].time
     
        
//        forall( j in jobs, l in 0..nbMchs-2, k,kp in ranks )   
//    		sum( i in machines )r[i,j,l]*h[i,k] + sum( i in machines)r[i,j,l]*P[i,j] <=
//    			V * ( 1 - z[j,k,l]) +
//    			V * ( 1 - z[j,kp,l+1] ) +
//    			sum( i in machines ) r[i,j,l+1]*h[i,kp];
//    
    

 }
 