/*********************************************
 * OPL 22.1.1.0 Model
 * Author: iefcyang
 * Creation Date: May 12, 2023 at 4:44:51 PM
 *********************************************/
 
// Number of Nodes (machines)
int NumberOfNodes = ...;

range Nodes = 0..NumberOfNodes-1;

// Numbers of PD points in each node.
int NumberOfPDPoints[Nodes] = ...;

// From-to time matrix sizes are different for nodes.
// No rectangular 3D array is possible; enumeric indexing is use.
// Input data are indexed values.
// Define the index structure.
tuple FromToStruct
{
	key int nID;
	key int fromPDID;
	key int toPDID;
}

// Define possible index combinations              
{FromToStruct} formToTimeIndexes = {<n,f,t>|n in Nodes, f,t in 0..NumberOfPDPoints[n]-1 };

// Read in from-to times of nodes from data file.
float FromToTimes[formToTimeIndexes ]=...;

 

// The loaded delivery operations are to be scheduled for each node.
// Two seccessive loaded operations required an loadless moving operation.
// The moving operations are not modeled in this CP model. Instead, 
// we ask CP to separate two loaded opeartions with the required moving time
// from the end PD point of the last operation to the start PD point of the nexe operation.
// The loaded operaion is therefore assigned with an integer type id 
// = fromPDID * number of PD points +toPDID.
// Therefore, the previous and the next type IDs will be associated with the required
// loadfree moving time.
tuple typeIDsStruct { int t1; int t2; float v; }


  
// For each node, the loadless moving times are indexed by the type IDs of 
// the previous and next operations.
// Each node will have this type-indexed moving times 
//{typeIDsStruct} movingTimes[n in Nodes] = 
//    { <s,e,FromToTimes[<n,s mod NumberOfPDPoints[n],  e div NumberOfPDPoints[n] >]> | s,e in 0..NumberOfPDPoints[n]*NumberOfPDPoints[n]-1 } ;
  


// Number of serial-operation-given jobs
int NumberOfJobs = ...;
range Jobs = 0..NumberOfJobs-1;
int V = 100000;

// The number of operations givend in each job
int NumberOfOperationsInJobs[Jobs] = ...;
 
// The feature of an operation
tuple OPStruct
{
	 int jobID;    // The Job this opertion is belong to
	 int seq;      // The operation sequence in this job
	 int nodeID;   // The node that perform this operation
	 int fromPDID; // The from PD point of this operation
	 int toPDID;   // The to PD point.
}

// The operations indexed with jobID, sequence,  node
{OPStruct} operations = ...;

// Add a dummy operation for each node (without jobID and seqID)
// The dummy is to show the type ID = 0 and remains at the head of the
// operation sequence on each node.
{OPStruct} dummyOperations = {<-1,-1,m,0,0> | m in Nodes };

// All operations are to be assigned with interval variables.
{OPStruct} allOPs = operations union dummyOperations;

// Set the sequence of the last operation in each job
int jobLast[j in Jobs ] = max( o in operations : o.jobID == j ) o.seq;

int opCounts[ i in Nodes ] = sum( o in allOPs: o.nodeID == i ) 1;

// Define set of last operations of the given jobs.
{OPStruct} lastOPs = {o|o in operations : o.seq == jobLast[o.jobID]};

// Define the type ID of each operation, which is dependent on the IDs of from to PD points
// and the number of PD points in each node.
//int deliveryTypes[o in allOPs ] =  o.fromPDID * NumberOfPDPoints[o.nodeID]+o.toPDID ;


 dvar float+ x[allOPs];           //  x[i]: start time of operation i
 dvar boolean z[allOPs,allOPs];   // z[op,o]: if( operation o follows op consecutively executed)

 minimize max(i in lastOPs)(  x[i] + FromToTimes[<i.nodeID,i.fromPDID,i.toPDID>] );
 subject to
 {
     forall( o,op in allOPs : o.jobID == op.jobID && o.seq - op.seq == 1 ) 
     	 x[op] + FromToTimes[<op.nodeID,op.fromPDID,op.toPDID>] <= x[o];
     	 
     forall( o in dummyOperations )
         x[o] == 0;
         
      forall( o,op in allOPs : o.nodeID == op.nodeID && o != op ) 	 
     	 x[op] + FromToTimes[<op.nodeID,op.fromPDID,op.toPDID>] + FromToTimes[<op.nodeID,op.toPDID, o.fromPDID>] <= x[o] + V * ( 1 - z[op,o] );
     	 
      forall(  o,op in allOPs : o.nodeID == op.nodeID && o != op)
         z[op,o] + z[o,op] == 1;
         
      forall( i in Nodes )
      	 sum( o, op in allOPs : o.nodeID == i && op.nodeID == i ) z[op,o] == opCounts[i];
      	 
 }