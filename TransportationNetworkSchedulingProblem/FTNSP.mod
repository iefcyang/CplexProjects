/*********************************************
 * OPL 12.9.0.0 Model
 * Author: iefcyang
 * Creation Date: Apr 5, 2023 at 1:38:37 PM
 *********************************************/
 
using CP;

// Number of Nodes (machines)
int NumberOfNodes = ...;

range Nodes = 0..NumberOfNodes-1;

// Numbers of PD points in each node.
int NumberOfPDPoints[Nodes] = ...;

tuple TimeIndexes
{
	key int nID;
	key int fromPDID;
	key int toPDID;
}

// Define possible index combinations              
{TimeIndexes} formToTimeIndexes = {<n,f,t>|n in Nodes, f,t in 0..NumberOfPDPoints[n]-1 };
//int total = sum( j in Nodes) NumberOfPDPoints[j];

// Read in from-to times
int FromToTimes[formToTimeIndexes ]=...;

tuple triplet { int t1; int t2; int v; }


//
{triplet} movingTimes[n in Nodes] = 
  { <s,e,FromToTimes[<n,s mod NumberOfPDPoints[n],  e div NumberOfPDPoints[n] >]> | s,e in 0..NumberOfPDPoints[n]*NumberOfPDPoints[n]-1 } ;
  
// We need to 

// In fixed problem the following information is not required
//int NumberOfTransferSites = ...;
//tuple TransferStation
//{
//	int fromNodeID;
//	int fromPDID;
//	int toNodeID;
//	int toPDID;
//};
//TransferStation TransferSites[0..NumberOfTransferSites-1] = ...;


// Number of serial-opetion-given jobs
int NumberOfJobs = ...;
range Jobs = 0..NumberOfJobs-1;

// The number of operations givend in each job
int NumberOfOperationsInJobs[Jobs] = ...;
 

tuple Operation
{
	 int jobID;
	 int seq;
	 int nodeID;
	 int fromPDID;
	 int toPDID;
}

// The operations indexed with jobID, sequence,  node
{Operation} operations = ...;

// Set the sequence of the last operation in each job
int jobLast[j in Jobs ] = max( o in operations : o.jobID == j ) o.seq;

int deliveryTypes[o in operations] =  o.fromPDID * NumberOfPDPoints[o.nodeID]+o.toPDID ;

// Decision variables

dvar interval opLoads[o in operations ] size FromToTimes[<o.nodeID,o.fromPDID,o.toPDID>];

// typese opLoads[o]
// dvar interval opMoves[o in operations ];
dvar sequence nodeSequences[ m in Nodes] 
in all( o in operations: o.nodeID == m ) opLoads[o] 
types all( o in operations: o.nodeID == m ) deliveryTypes[o];
 

minimize max( j in Jobs, o in operations : o.jobID == j && o.seq == jobLast[j]) endOf( opLoads[o] );

subject to
{
 	forall( m in Nodes ) noOverlap( nodeSequences[m], movingTimes[m],1);
 	forall( j in Jobs, oPrev in operations, o in operations : oPrev.jobID == o.jobID == j && o.seq == oPrev.seq + 1 )
		endBeforeStart( opLoads[oPrev], opLoads[o]);		
}

// almost done only data left
// Second changed

