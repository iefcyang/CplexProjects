/*********************************************
 * OPL 12.9.0.0 Model
 * Author: user
 * Creation Date: May 21, 2023 at 9:33:47 AM
 *********************************************/
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

 

// The loaded delivery operations are to be scheduled for each node.
// Two seccessive loaded operations required an loadless moving operation.
// The moving operations are not modeled in this CP model. Instead, 
// we ask CP to separate two loaded opeartions with the required moving time
// from the end PD point of the last operation to the start PD point of the nexe operation.
// The loaded operaion is therefore assigned with an integer type id 
// = fromPDID * number of PD points +toPDID.
// Therefore, the previous and the next type IDs will be associated with the required
// loadfree moving time.
//tuple typeIDsStruct { int t1; int t2; int v; }


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

{OPStruct} opOnNodes[i in Nodes] = {o| o in operations : o.nodeID == i };
{OPStruct} opOfJobs[j in Jobs] = {o| o in operations : o.jobID == j };;
{OPStruct} lastOPs = {  op | j in Jobs, op in opOfJobs[j] : op.seq == card(opOfJobs[j]) - 1 };

// Preporcessing: set up properties for each node, job


// Add a dummy operation for each node (without jobID and seqID)
// The dummy is to show the type ID = 0 and remains at the head of the
// operation sequence on each node.
{OPStruct} dummyOperation[m in Nodes] = {<-1,-1,m,0,0>};

{OPStruct} dummies = { o | i in Nodes, o in dummyOperation[i] };
 
// All operations are to be assigned with interval variables.
{OPStruct} allOPs = operations union dummies;


 dvar int+ x[allOPs];           //  x[i]: start time of operation i
 dvar boolean z[allOPs,operations];   // z[op,o]: if( operation o follows op consecutively executed)

 minimize max(i in lastOPs)(  x[i] + FromToTimes[<i.nodeID,i.fromPDID,i.toPDID>] );
 subject to
 {
     forall( j in Jobs, op, o in opOfJobs[j] : o.seq - op.seq == 1 ) 
     	 x[op] + FromToTimes[<op.nodeID,op.fromPDID,op.toPDID>] <= x[o];
     	 
     forall( o in dummies )
         x[o] == 0;
        
     // Constraints for operations o and op on the same node 
      forall( i in Nodes, op in opOnNodes[i] union dummyOperation[i], o in opOnNodes[i] : o != op ) 	 
     	 x[op] + FromToTimes[<op.nodeID,op.fromPDID,op.toPDID>] + FromToTimes[<op.nodeID,op.toPDID, o.fromPDID>] <= x[o] + V * ( 1 - z[op,o] );
     	 
     // For those operations on the same node
      
      // each operation o on a node must have a previous linked operation (may be the dummy one)	 
      forall( i in Nodes )
      {
           sum( op in dummyOperation[i], o in opOnNodes[i] ) z[op,o] == 1;	
           forall( op in opOnNodes[i] ) 
             	sum( o in opOnNodes[i]: op != o ) z[op,o] <= 1;          
          forall( o in opOnNodes[i] ) 
             	sum( op in opOnNodes[i] union dummyOperation[i] : op != o ) z[op,o] == 1;
           forall( op, o in opOnNodes[i] : o != op) 
             	z[op,o]+z[o,op] <= 1;
    }
      
   

 }