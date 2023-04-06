/*********************************************
 * OPL 12.9.0.0 Model
 * Author: iefcyang
 * Creation Date: Mar 30, 2023 at 1:09:48 PM
 *********************************************/
int numberOfProducts = ...;
range products = 1..numberOfProducts;

int numberOfOrders = ...;
range orders = 1..numberOfOrders;

int numberOfPods = ...;
range pods = 1..numberOfPods;

int numberOfBatches = ...; // 
range batches = 1..numberOfBatches;

int orderLimitInBatch = ...;

// if order o has product p a[p,o] = 1; otherwise 0.
int a[products, orders ] = ...;
int x[products,pods] = ...;

// Decision variables
dvar boolean z[orders, batches]; // order n is assigned to batch k
dvar boolean w[batches,pods];
dvar boolean u[products,batches]; // whether product i appears in batch k

minimize max( k in batches, m in pods ) sum(k in batches, m in pods) w[k,m] ;
subject to
{
	// (1) An order is assigned to a batch
	forall( n in orders) 
		sum( k in batches ) z[n,k] == 1;
		
	// (2) Each batch contains at most 
	forall( k in batches ) 
		sum( n in orders ) z[n,k] <= orderLimitInBatch;
	
	// (3) Restrict u[i,k] = 1 or 0;
	// If product i appears in batch k (u[i,k]=1) then at least one order in batch k has product i.
	// In a batch if a product exist (u[i,k]=1) then at most numberOrOrders
	forall( i in products, k in batches ) 
			sum( n in orders )( a[ i,n] * z[n,k] ) <= numberOfOrders * u[i,k];
		//sum( n in orders ) a[n,i] * z[n,k] <= numberOfProducts * u[i,k];
	
	// (4) If u[i,k]=0 always true. Yet, if u[i,k] = 1, must more than a pod carrys product i 
	forall( i in products, k in batches)
	   sum( m in pods )( x[i,m]*w[k,m] ) >= u[i,k];
}

