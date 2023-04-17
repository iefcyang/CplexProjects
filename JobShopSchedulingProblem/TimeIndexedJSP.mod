 
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

// The worst case, operations are executed one-after-the-other.
int worstTime = sum( j in jobs, h in machines) Ops[j,h].time;
range slots = 0..worstTime-1;


int P[j in jobs, i in machines ] = max( h in machines : Ops[j,h].mID == i ) Ops[j,h].time;

 dvar int+ Cmax;  // Makespan


 dvar boolean x[machines, jobs, slots];   // z[i,j,t]: job j on machine i starts at time t

 
 minimize Cmax;
 
 subject to
 {
   
    // Eeah operation has been started once at a time slot.  
    forall( i in machines, j in jobs ) 
    	sum( t in slots ) x[i,j,t] == 1;
    
    // Cmax is greater or equal to each operation's end time
//    forall( i,h in machines, j in jobs: Ops[j,h].mID == i ) 
//    	sum( t in slots ) (t + Ops[j,h].time ) * x[i,j,t] <= Cmax;  	
    forall( i,h in machines, j in jobs  ) 
    	sum( t in slots ) (t + P[j,i]) * x[i,j,t] <= Cmax;  	
    	
    // In machine i for each job the operation period can have only one start 1   	  	
 //  forall( i in machines, t in slots ) sum( j in jobs, tp in (t-P[j,i]+1)..t : tp >= 0 ) x[i,j,tp] <= 1; 
   forall( i in machines, t in slots ) sum( j in jobs, tp in (t-P[j,i]+1)..t : tp >= 0 ) x[i,j,tp] <= 1; 
   
    // Next operation start time should be larger than the previous one
    forall( j in jobs, h in 1..nbMchs-1)
     	sum( t in slots) ( t + Ops[ j,h-1].time ) * x[Ops[j,h-1 ].mID,j,t] <=
     	sum( t in slots ) t * x[Ops[j,h].mID,j,t] ;
     	
 }
 