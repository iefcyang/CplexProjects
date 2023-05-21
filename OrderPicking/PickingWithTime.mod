/*********************************************
 * OPL 12.9.0.0 Model
 * Author: user
 * Creation Date: May 7, 2023 at 9:03:43 PM
 *********************************************/

 int S = ...; // number of SKUs
 range SKUs = 1..S;
 int n = ...; // number of Orders
 range Orders = 1..n;
 int m = ...; // numver of Racks
 range Racks = 1..n;
 int K = ...; // number of Stations
 range Stations = 1..K;
 int C = ...; // number of chutes
 range Chutes = 1..C;
 int O[Orders,SKUs] = ...; // O[i,s] = 1, if order i contains SKU s
 int q[Orders,SKUs] = ...; // q[i,s] = number of units of SKU s required by order i
 int R[Racks,SKUs]=...; // R[j,s] = 1, if radk j contains SKU s
 int L = ...; // number of Slots;
 range Slots = 1..L; 
 int d = ...; // limit of orders per station
 int upick = ...; // time for picking one unit of SKU
 int uset = ...; // setup time between two adjacent rack movements
 int Q; // The total number of rack movements
 
 dvar boolean w[Orders,Stations]; // w[i,k] = 1, if order i is processed by station k
 dvar boolean x[Orders,Stations,Slots]; // x[i,k,l] = 1, if order i is in station k at slot l
 dvar boolean y[Racks,Stations,Slots]; // y[j,k,l] = 1, if rack j is in station k at stlot l
 dvar boolean z[Orders, Racks, SKUs, Stations, Slots]; // z[i,j,s,k,l] = 1, if SKU s is required in order i delivered by rack j at station k at slot l
 dvar float+ e[Racks,Stations,Slots]; // e[j,k,l] = 1, if rack j visits station k at slot l is different from the one visited at l-1.=
 dvar float+ gstart[Racks,Stations,Slots]; // gstart[j,k,l]: start picking time of rack j at station k at slot l
 dvar float+ gend[Racks,Stations,Slots]; // gend[j,k,l]: end picking time of rack j at station k at slot l
 dvar boolean sig[Racks,Stations, Slots, Stations, Slots]; // sig[j,k,l,k,k',l'] = 1, if start picking time of rack j at station k at slot l is greater than or equal to the end time of that rack at station k' at slot l'.
 dvar boolean tau[Racks,Stations, Slots, Stations, Slots]; // tau[j,k,l,k,k',l'] = 1, if start picking time of rack j at station k' at slot l' is greater than or equal to the end time of that rack at station k at slot l.
 
 minimize Q;
 subject to
 {
 //(1) for each SKU in order must be fulfilled
 forall(i in Orders, s in SKUs )
   sum(j in Racks, k in Stations, l in Slots)z[i,j,s,k,l] >= O[i,s];
   
   // (2) sku s delivered to station k for order i at slot l.
   forall( i in Orders, j in Racks, s in SKUs, k in Stations, l in Slots) 
 		x[i,k,l] >= z[i,j,s,k,l];
 		
 	// (3)
 	forall( i in Orders, k in Stations)
 	   sum( l in Slots) x[i,k,l] <= w[i,k] * L;
  
 }