/*********************************************
 * OPL 12.9.0.0 Model
 * Author: user
 * Creation Date: Mar 26, 2023 at 1:01:16 AM
 *********************************************/

 int N = ...; // number of orders
 int M = ...; // number of racks
 int S = ...; // number of stations
 int K = ...; // number of SKUs
 int w = ...; // order limit in each station
 int C = ...; // number of chutes in each station
 int Q = ...; // number of buffers in each station
 
 int T = N; // maximum number of time slots
 // int T = N * M; // maximum number of time slots
 range Orders = 1..N;
 range Racks = 1..M;
 range Stations = 1..S;
 range Slots = 1..T;
 range SKUs = 1..K;
 
 {int} SKUInOrder[Orders] = ...;
 {int} SKUOnRack[Racks]= ...;
 
 int Oset[i in Orders, k in SKUs] = k in SKUInOrder[i] ? 1 : 0;
 int Rset[j in Racks, k in SKUs] = j in SKUOnRack[j] ? 1 : 0;
 
// y[i,s] order i is assigned to station s
 dvar boolean y[Orders, Stations ]; 
  
 // Rack j dispatched to station s at slot t
 // x[j,s,t] rack j visits station s  in slot t
 dvar boolean x[Racks, Stations, Slots]; 
 
  // o[i,s,t] order i assigned to station s and processed in slot t
 dvar boolean o[Orders, Stations, Slots]; 
  
 // z[j,s,sp,t] rack j moves from station s to sp in slot t
 dvar boolean z[Racks, Stations, Stations, Slots];
 
  // L[k,i,s,t] SKU k fulfills order i at station s in slot t
 dvar boolean L[SKUs, Orders, Stations, Slots];
 
 // r[s,t] racks visits station s in t are different in t-1
 dvar boolean r[Stations,2..T];
 
 // (1) objective
 minimize sum(t in 2..T, s in Stations)r[s,t] - sum( t in 2..T-Q, j in Racks, s in Stations, sp in Stations : sp != s)z[j,s,sp,t+Q];
 
 subject to
 {
 	//(2) For each order, only one station is assigned to
  	forall( i in Orders) sum( s in Stations) y[i,s] == 1;
  	
  	//(3) At each station, at most w orders are assigned here.
  	forall( s in Stations) sum( i in Orders ) y[i][s] <= w;
  	
  	//(4) Each station at each time slot at most one rack is processing    
  	forall( s in Stations, t in Slots )	 sum( j in Racks ) x[j,s,t] <= 1;
  				    
  	//(5) In each slot each rack can serever at most one station
  	forall( j in Racks, t in Slots ) sum(s in Stations ) x[j,s,t] <= 1;
  	  	     
  	//(6) 

  	forall( j in Racks, s,sp in Stations : sp != s, t,tp in Slots : t != tp )
  	    1.0 - ( x[j,s,t] * x[j,sp,tp] - abs( sum( t1 in 1..t)r[s,t1] - sum(t2 in t..tp)r[sp,t2] ) - Q )  <= M * ( 1 - z[j,sp,s,t] );
  	  	         
  	//(7) 

  	forall( j in Racks, s,sp in Stations : sp != s, t,tp in Slots : t != tp )
  	    Q - abs( sum( t1 in 1..t)r[s,t1] - sum(t2 in t..tp)r[sp,t2] )  <= M * ( 1 - x[j,s,t] * x[j,sp,tp] );
  	  	
  	//(8) In each station, each time slot at most C orders are processing.
  	forall( s in Stations, t in Slots )	 sum( i in Orders ) o[i,s,t] <= C;
  				    
    //(9) For each order, at each time slot at most 1 SKU is fulfilled.
  	forall( i in Orders, t in Slots ) sum( s in Stations ) o[i,s,t] <= 1;
  	
  	//(10) Avoid  ..1.0.1.. Oder should be processed in a set of consecutive slots.
  	forall( i in Orders, s in Stations, t in 1..T-1, d in 2..T-t)	
  		o[i,s,t] + o[i,s,t+d] <= 1 + o[i,s,t+1];
  		
  	//(11) If order i is not processed at station s (y[i,s]=0), no sku is filled  in any slot 
  	forall( i in Orders, s in Stations )
  	    y[i,s] <= sum( t in Slots) o[i,s,t];
  	    
  	//(12) If order i processed at station s (y[i,s]=1), the skus filled can not exceed the nuber of racks
  	forall( i in Orders, s in Stations )
  	    sum( t in Slots ) o[i,s,t] <= M * y[i,s];
  	    
  	//(13) Order i has SKU k filled at station s, then the fillment must appear
  	// Each SKU k required by order i assigned to station s must be fulfilled.
  	forall( i in Orders, k in SKUs, s in Stations )
  	    sum( t in Slots ) L[k,i,s,t] >= Oset[i,k] * y[i,s]; 
  	    
  	//(14) If SKU k is to be filled for order i at station s in slot t, a rack suport k must visit s at t
  	forall( i in Orders, k in SKUs, s in Stations, t in Slots)
  		2 * L[k,i,s,t] <= o[i,s,t] * Oset[i,k] + sum( j in Racks ) Rset[j,k] * x[j,s,t];
  		
  	//(15)
  	forall( s in Stations, t in 2..T )
  	    r[s,t] == 0.5 * sum( j in Racks ) abs( x[j,s,t]- x[j,s,t-1] );
  	    
  	//(16)
  	forall( s in Stations) r[s,1] == 1;
 }
 
