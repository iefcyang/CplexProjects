/*********************************************
 * OPL 12.9.0.0 Model
 * Author: iefcyang
 * Creation Date: Mar 30, 2023 at 9:23:27 AM
 *********************************************/

 int numberOfJobs = ...;
 range jobs = 1..numberOfJobs;
 float setupTime[jobs,jobs] = ...;
 
 dvar boolean ass[jobs,jobs];
 
 minimize  sum( j in jobs, p in jobs) setupTime[j,p] * ass[j][p];
 
subject to
{
	forall( row in jobs) sum( col in jobs ) ass[row,col] == 1;
	forall( col in jobs ) sum(row in jobs ) ass[row,col] == 1;
}



 