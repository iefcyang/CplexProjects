/*********************************************
 * OPL 22.1.1.0 Model
 * Author: markchen
 * Creation Date: Apr 20, 2023 at 5:54:19 PM
 *********************************************/

int nbJobs = ...;
int nbMchs = ...;

range Jobs = 0..nbJobs-1;
range Machines = 0..nbMchs-1;
// Mchs is used both to index machines and operation position in job

tuple Operation {
  int mch; // Machine
  float pt;  // Processing time
};

//float p[Machines, Jobs] = ...;
//float q[Machines, Jobs, Jobs] = ...;
//float init[Machines, Jobs] = ...;
float p[Machines, Jobs] = ...;
float q[Machines, Jobs, Jobs] = ...;
float init[Machines, Jobs] = ...;
int oj[Jobs] = ...;
int oi[Machines] = ...;
int max_oj = ...;

Operation Ops[Jobs][0..max_oj-1] = ...;
int J[Machines][Jobs] = ...;
//int P[i in Machines, j in Jobs] = Ops[j][i].pt;



float V = sum(i in Jobs, j in 0..max_oj-1)Ops[i][j].pt;
dvar float+ Cmax;
dvar float+ x[Machines, Jobs];
dvar boolean l[Machines, Jobs, Jobs];

minimize Cmax;

subject to{
	
	forall(j in Jobs, h in 0..oj[j]-2)
    	x[Ops[j,h+1].mch,j]>=(x[Ops[j,h].mch, j]+Ops[j,h].pt);
    forall(i in Machines, j,k in 0..oi[i]-1)
      x[i][J[i][j]]+p[i][J[i][j]]+q[i][J[i][j]][J[i][k]]-x[i][J[i][k]] <= V*(1-l[i][J[i][j]][J[i][k]]);
      
    forall(i in Machines,k in 0..oi[i]-1)
//      init[i][J[i][k]]-x[Ops[J[i][k],0].mch][J[i][k]] <= V*sum(j in 0..oi[i]-1)l[i][J[i][j]][J[i][k]];
      init[i][J[i][k]]-x[i][J[i][k]] <= V*sum(j in 0..oi[i]-1)l[i][J[i][j]][J[i][k]];
    
    forall(j in Jobs)
  		Cmax >= x[Ops[j,oj[j]-1].mch, j] + Ops[j,oj[j]-1].pt;
  	
  	forall(i in Machines, j in Jobs) x[i,j] >= 0;
  	forall(i in Machines)
  	  sum(j,k in 0..oi[i]-1: j!=k)l[i][J[i][j]][J[i][k]] <= oi[i]-1;
 	forall(i in Machines)
  	  sum(j,k in 0..oi[i]-1: j!=k)l[i][J[i][j]][J[i][k]] >= oi[i]-1;
  	   
  	forall(i in Machines, k in 0..oi[i]-1)
  		sum(j in 0..oi[i]-1)l[i][J[i][j]][J[i][k]] <= 1;
  	
  	forall(i in Machines, j in 0..oi[i]-1)
  		sum(k in 0..oi[i]-1)l[i][J[i][j]][J[i][k]] <= 1;

 	  
}