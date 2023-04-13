 
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

int n = nbJobs;
range ranks = 0..n-1;

 dvar int+ Cmax;  // Makespan
dvar int+ h[machines,ranks];

int V = 10000;

 dvar boolean x[machines, jobs, ranks];   // z[i,j,k]: job j on machine i starts at rank k

 
 minimize Cmax;
 
 subject to
 {
   
    // On each machine, each rank is assigned to one job;
    // Loop through all jobs on a machine with a rank, only one 1 is given
    forall( i in machines, k in ranks ) 
    	sum( j in jobs ) x[i,j,k] == 1;
    
    // For a job on a machine only one rank k is assigned
    forall( i in machines, j in jobs ) 
    	sum( k in ranks ) x[i,j,k] == 1;
    	
    // For each rank on a machine 
    forall( i in machines, k in 0 .. n-1)
       h[i,k]+sum( j in jobs, d in machines: Ops[j,d].mID == i ) Ops[j,d].time * x[i,j,k] <= h[i,k+1];
       
    	
//	forall( j in jobs, h in 1..nbChms-1)
//	   sum(i in machins) 
     	
 }
 