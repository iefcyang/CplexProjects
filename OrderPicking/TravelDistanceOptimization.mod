/*********************************************
 * OPL 12.9.0.0 Model
 * Author: iefcyang
 * Creation Date: Apr 1, 2023 at 1:06:14 PM
 *********************************************/
int numShelves = ...;
int numDepods = ...;
int numNodes = numShelves + numDepods;

range V = 1..numNodes; //nodes  // V

range Vs = 1..numShelves; // shelves 
range Vd = numShelves+1..numNodes; // depods

tuple Edge
{
   int From;
   int To;
}
//int numEdges=...;
//range E = 1..numEdges; // Edges  // E
//{Edge} edges = ...;
int e[V,V] = ...;

int numItems = ...;
range P = 1..numItems; // items  // P
float weightOfItems[P] = ...; // wp

{int} shelvesStoreItem[P] = ...; // Vsp

int itemCounts[P,Vs] = ...; // nps

{int} itemSetOnShelf[Vs] = ...;  // ?


int numOrders = ...;
range O = 1..numOrders; // O

{int} itemListInOrder[O] = ...; // Po

int numBatches = ...;
{int} batchesLeaveDepot[Vd]=...; // Bd
range B = 1..numBatches; // B


float d[V,V] = ...;           // dij
int c; // maximum payload of a robot  // c

// Routing of a batch
dvar boolean x[V,V,B,Vd]; // xijbd // in batch b robot leave from depod d and node j is visited after i 
// Itemps collected in a batch
dvar boolean z[P,Vs,B,Vd];   // zpsbd //item p in shelf s collected  in batch b leaving from depod d
// Order fulfilled in a batch
dvar boolean w[O,B,Vd];   // wobd  order o is collected in batch b leaving from depod d;

minimize sum( i,j in V: e[i,j] == 1, d in Vd, b in batchesLeaveDepot[d] ) d[i,j] * x[i,j,b,d];

subject to
{
	forall( i in V, d in Vd,  b in batchesLeaveDepot[d] ) sum( j in V ) x[i,j,b,d] <= 1;
	forall( i in V, d in Vd,  b in batchesLeaveDepot[d] ) sum( j in V ) x[j,i,b,d] <= 1;	
	
	forall( d in Vd,  b in batchesLeaveDepot[d]) sum( p in P, s in shelvesStoreItem[p] ) z[p,s,b,d] * weightOfItems[P] <= c;
	
	
	
	
	
}

