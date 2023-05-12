/*********************************************
 * OPL 22.1.1.0 Model
 * Author: iefcyang
 * Creation Date: May 8, 2023 at 10:05:27 AM
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
 float delta = ...; // portion of extra orders above the average for a station
 float upick = ...; // time for picking one unit of SKU
 float uset = ...; // setup time between two adjacent rack movements
 int Q; // The total number of rack movements
 float limit = (1.0+delta)* n / K;
 int M = 10000;
 dvar boolean w[Orders,Stations]; // w[i,k] = 1, if order i is processed by station k
 dvar boolean x[Orders,Stations,Slots]; // x[i,k,l] = 1, if order i is in station k at slot l
 dvar boolean y[Racks,Stations,Slots]; // y[j,k,l] = 1, if rack j is in station k at stlot l
 dvar boolean z[Orders, Racks, SKUs, Stations, Slots]; // z[i,j,s,k,l] = 1, if SKU s is required in order i delivered by rack j at station k at slot l
 dvar float+ e[Racks,Stations,Slots]; // e[j,k,l] = 1, if rack j visits station k at slot l is different from the one visited at l-1.=
 dvar float+ gstart[Racks,Stations,Slots]; // gstart[j,k,l]: start picking time of rack j at station k at slot l
 dvar float+ gend[Racks,Stations,Slots]; // gend[j,k,l]: end picking time of rack j at station k at slot l
 dvar boolean sig[Racks,Stations, Slots, Stations, Slots]; // sig[j,k,l,k,k',l'] = 1, if start picking time of rack j at station k at slot l is greater than or equal to the end time of that rack at station k' at slot l'.
 dvar boolean tau[Racks,Stations, Slots, Stations, Slots]; // tau[j,k,l,k,k',l'] = 1, if start picking time of rack j at station k' at slot l' is greater than or equal to the end time of that rack at station k at slot l.
 

 
 minimize sum( j in Racks, k in Stations, l in 2..L)e[j,k,l];
 
 subject to
 {
 	//(1) for each SKU in order must be fulfilled
 	forall(i in Orders, s in SKUs )
   		sum(j in Racks, k in Stations, l in Slots)z[i,j,s,k,l] >= O[i,s];
   
 	// (2) sku s delivered to station k for order i at slot l.
 	forall( i in Orders, j in Racks, s in SKUs, k in Stations, l in Slots) 
 		x[i,k,l] >= z[i,j,s,k,l];
 		
 	// (3) if order i is at station k, the count of  slot is smaller than the L
 	forall( i in Orders, k in Stations)
 	   sum( l in Slots) x[i,k,l] <= w[i,k] * L;
  
 	// (4) Each order can only be processed by one station
 	forall( i in Orders)	
   		sum(k in Stations) w[i,k] <= 1;
  	
  	//(5) the number of orders processed by each station is lower than the limit
 	forall( k in Stations)
   		sum( i in Orders) w[i,k] <=  limit;
  	  
  	//(6) the number orders under processing in each slot is within the number of chutes
 	forall( k in Stations, l in Slots)
   		sum( i in Orders) x[i,k,l] <= C;
  	  
 	// (7) an order is processed at a set of consecutive slots
 	forall( i in Orders, k in Stations, l,lp,lpp in Slots: l < lp < lpp)
   		x[i,k,l] + x[i,k,lpp] <= 1 + x[i,k,lp];
  	    
 	//(8) in each station, each slot only one rack is assigned 
 	forall( k in Stations, l in Slots)
   		sum( j in Racks) y[j,k,l] <= 1;
  	      
 	//(9) if SKU s is delivered at slot t in station k, the assigned rack must have SKU s.
 	forall( i in Orders, j in Racks, s in SKUs, k in Stations, l in Slots ) 
   		z[i,j,s,k,l] <= y[j,k,l] * R[j,s];
 				
 	//(10) the end time of a rack supply is the start time plus the handling time
 	forall( j in Racks, k in Stations, l in Slots)
   		gstart[j,k,l] + upick * sum( i in Orders, s in SKUs) q[i,s]*z[i,j,s,k,l] == gend[j,k,l];
 				  
 	//(11) for a successive pick the start time should be larger than the end time of the previous 
 	// operation and a setup time
 	forall( j,jp in Racks, k in Stations, l in 2..L)
   		gend[jp, k, l-1] + uset * e[j,k,l] <= gstart[j,k,l];
 				   
 	//(12) nonlinear the processing block are not overlapped
 	//(13)	 if(  k,l > kp,lp ) start(k,l) > end(kp,lp)
 	forall( j in Racks,k,kp in Stations, l,lp in Slots)
   		gend[j,kp,lp] <= gstart[j,k,l] + M * ( 1 - sig[j,k,l,kp,lp] );
   		
 	// (14) else end(k,l) < start[kp,lp] (15) xx
 	forall( j in Racks,k,kp in Stations, l,lp in Slots)
   		gend[j,k,l]  <= gstart[j,kp,lp] + M * sig[j,k,l,kp,lp];
   		
 	//(16) 
 	forall( j in Racks, k in Stations, l in 2..L)
   		y [j,k,l]-y[j,k,l-1] <= e[j,k,l];
 }