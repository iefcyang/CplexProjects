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
int FromToTimes[formToTimeIndexes ]=...;

// The loaded delivery operations are to be scheduled for each node.
// Two seccessive loaded operations required an loadless moving operation.
// The moving operations are not modeled in this CP model. Instead, 
// we ask CP to separate two loaded opeartions with the required moving time
// from the end PD point of the last operation to the start PD point of the nexe operation.
// The loaded operaion is therefore assigned with an integer type id 
// = fromPDID * number of PD points +toPDID.
// Therefore, the previous and the next type IDs will be associated with the required
// loadfree moving time.
tuple typeIDsStruct { int t1; int t2; int v; }

// For each node, the loadless moving times are indexed by the type IDs of 
// the previous and next operations.
// Each node will have this type-indexed moving times 
{typeIDsStruct} movingTimes[n in Nodes] = 
    { <s,e,FromToTimes[<n,s mod NumberOfPDPoints[n],  e div NumberOfPDPoints[n] >]> | s,e in 0..NumberOfPDPoints[n]*NumberOfPDPoints[n]-1 } ;
  


// Number of serial-operation-given jobs
int NumberOfJobs = ...;
range Jobs = 0..NumberOfJobs-1;

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

// Define set of last operations of the given jobs.
{OPStruct} lastOPs = {o|o in operations : o.seq == jobLast[o.jobID]};

// Define the type ID of each operation, which is dependent on the IDs of from to PD points
// and the number of PD points in each node.
int deliveryTypes[o in allOPs ] =  o.fromPDID * NumberOfPDPoints[o.nodeID]+o.toPDID ;

// Decision variables
// Each operation (including the dummy one) have an interval variable associated.
dvar interval opLoads[o in allOPs ] size FromToTimes[<o.nodeID,o.fromPDID,o.toPDID>];

// Each node have a sequence variable to deal with the loaded operations and its own dummy operations
dvar sequence nodeSequences[ m in Nodes] 
	in all( o in allOPs: o.nodeID == m ) opLoads[o] 
	types all( o in allOPs: o.nodeID == m ) deliveryTypes[o];
 
 
minimize max( o in lastOPs ) endOf( opLoads[o] );
//minimize max( j in Jobs, o in operations : o.jobID == j && o.seq == jobLast[j]) endOf( opLoads[o] );

subject to
{
  	// The interval variable for the dummy operations must be in the zero's position
  	forall( m in Nodes )
  	   forall( o in dummyOperations: o.nodeID == m )
    		first( nodeSequences[m], opLoads[o]);
    
    // In each node sequence, no operlap between intervals and must be separated with the type-indexed moving times
 	forall( m in Nodes ) noOverlap( nodeSequences[m], movingTimes[m],1);
 	
 	// For each job the operations must be processed one after another
 	forall( j in Jobs )
 	   forall( oPrev in operations : oPrev.jobID == j, o in operations :  o.jobID == j && o.seq == oPrev.seq + 1 )
		   endBeforeStart( opLoads[oPrev], opLoads[o]);		
}

