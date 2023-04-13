/*********************************************
 * OPL 22.1.1.0 Model
 * Author: iefcyang
 * Creation Date: Apr 13, 2023 at 12:18:20 PM
 *********************************************/
 
 /*********************************************
 * OPL 22.1.1.0 Model
 * Author: iefcyang
 * Creation Date: Apr 13, 2023 at 12:18:20 PM
 *********************************************/
 
 
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

int V = 1000;

 dvar int+ x[machines,jobs];           //  x[i,j]: start time of job j on machine i
 dvar boolean z[machines, jobs, jobs];   // z[i,j,k]: job j precedes jobk k on machine i
 dvar int+ Cmax;  // Makespan
 
 minimize Cmax;
 
 subject to
 {
    // Start time of operation h of a job should be later than the end time of its provius operation
    forall( j in jobs, h in 1..lastID ) 
    	x[Ops[j,h-1].mID,j] + Ops[j,h-1].time <= x[Ops[j,h].mID,j];
    	
    	

       
     // Start time of operation block of job k should be larger thand the end time
     // of block of job j, if job k is processed after job j. Otherwise (z=0), no constraint applied
    
     forall( i,h in machines, j,k in jobs : j < k && Ops[h,j].mID == i )
        x[i,j] + Ops[h,j].time <= x[i,k] + V * ( 1 - z[i,j,k]  );
       
     // Otherwise (z=0), this constraint make sure start time of job j is greater than job k.
     // If z = 1, this constraint does nothing.
     // Two constraints make no overlapped blocks on a machine	
    forall( i,h in machines, j,k in jobs : j < k && Ops[h,k].mID == i )
       x[i,k] + Ops[h,k].time <= x[i,j] + V * z[i,j,k]; 
         
    // Cmax is greater than the end time of the last operation of each job
    forall( j in jobs ) 
    	Cmax >= x[Ops[j,lastID].mID, j ] + Ops[j,lastID].time;
 }
 
 
 
