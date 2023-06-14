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
int FromToTimes[formToTimeIndexes ]=...;

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

// Set the sequence of the last operation in each job
int jobLast[j in Jobs ] = max( o in operations : o.jobID == j ) o.seq;

// Define set of last operations of the given jobs.
{OPStruct} lastOPs = {o|o in operations : o.seq == jobLast[o.jobID]};

// The number of operations processed on each node
int opCounts[ i in Nodes ] = sum( o in operations: o.nodeID == i ) 1 ;

// The initial moving time of the vehicle to the from PD point of the operation.
int firstProcessedTime[o in operations] =  FromToTimes[<o.nodeID,0,o.fromPDID>];

 //  x[o]: start time of operation o
 dvar int+ x[operations];    
      
  // z[op,o]: if( operation o follows op consecutively executed)
 dvar boolean z[operations,operations]; 

// Goal: minimize the maximal span
 minimize max(i in lastOPs)(  x[i] + FromToTimes[<i.nodeID,i.fromPDID,i.toPDID>] );

 subject to
 {

     // The q-th operation of a job must be processed after the (q-1)-th operation
     forall( op, o in operations : o.jobID == op.jobID && o.seq - op.seq == 1 ) 
     	 x[op] + FromToTimes[<op.nodeID,op.fromPDID,op.toPDID>] <= x[o];
     	 
     // In a node, the successive operation can be processed after the previous operations is delivered to its PD point and the 
     // vehicle have transfered to the start PD point of the successive operation.
      forall( op, o in operations : o.nodeID == op.nodeID && o != op ) 	 
     	 x[op] + FromToTimes[<op.nodeID,op.fromPDID,op.toPDID>] + FromToTimes[<op.nodeID,op.toPDID, o.fromPDID>] <= x[o] + V * ( 1 - z[op,o] );
     
    // Constraints on the successive flag z[op,o] where operation o is the successive operation after op is processed on the same node.
    // Total number of the flag is the number of operations on the same node minus 1.
       forall( i in Nodes )
            sum( op, o in operations: op.nodeID == i && o.nodeID == i && o != op ) z[op,o] == opCounts[i] - 1;	 
	 
     // Row-wise if z[op,o] = 1 then op->o  For a given operation, at most one operation is succeded. 
    //  If no operations are succeeded, it is the last processed operation in the node.
      forall( i in Nodes )
         forall( op in operations: op.nodeID == i )
              sum( o in operations: o.nodeID == i && op != o ) z[op,o]  <= 1;	       

        // Column-wise 
        // For a given operation, at most one operation is directly preceeded to it.
        // If no any proceeding operation, it is the first processed operation on the node.
        forall( i in Nodes )
            forall( o in operations: o.nodeID == i )
                 sum( op in operations: op.nodeID == i && op != o )  z[op,o] <= 1;
	 
        // Symmetric pairs
        //  If operation o is successive to op, then the reversed flag must be 0.
        forall( i in Nodes )
            forall(  op, o in operations: op.nodeID == i && o.nodeID == i && o != op ) z[op,o]+z[o,op] <= 1;
                       
         //  The first operation at each node need to be started after the first transpotation form 0 to its start PD point
        forall( i in Nodes )
            forall( o in operations: o.nodeID == i )
                  firstProcessedTime[o] <= x[o] +  V * sum( op in operations: op.nodeID == i && op != o ) z[op,o];
                 
 }