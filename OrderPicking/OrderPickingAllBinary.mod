/*********************************************
 * OPL 12.9.0.0 Model
 * Author: user
 * Creation Date: Mar 26, 2023 at 1:01:16 AM
 *********************************************/

 int n = ...;
 int m = ...;
 int C = ...;
 int T = n*m;
 range Orders = 1..n;
 range Racks = 1..m;
 range Slots = 1..T;
 
 {string} SKUs = ...;
 {string} SKUInOrder[Orders] = ...;
 {string} SKUOnRack[Racks]= ...;
  
 {int} RackHostSKU[SKUs];
 
 
 // Rack j dispatched at slot t
 dvar boolean x[Racks][Slots];
 
 // At slot t SKUs of order i is fullfilled ( NOTE: some z[s][i][t] are not of concerned if s is not in order i)
 dvar boolean z[SKUs][Orders][Slots];
 // dvar boolean z[SKUInOrder[Orders]][Orders][Slots];
 // At slot t the rack is changed
 dvar float+ alpha[Slots];
 // At slot t order i 
 // state: 1-> under processing and fullfilled, 0-> not in processing
 // between 0 and 1 -> processing but not filled 
 dvar boolean y[Orders][Slots];
 
 execute
 {
 	for( var s in SKUs)
 	{
 		//RackHostSKU[s]={};
 		for( var j in Racks)
 		{
 			var hit = false;	 		
 			for( var sku in SKUOnRack[j])
 				if( sku == s ) 	
 				{
 				   hit = true;
 				   break; 				
 				}
   			if( hit ) RackHostSKU[s].add( j );
   		}   		 				
 	} 
 }
 
 
 minimize sum(t in 2..T) alpha[t];
 subject to
 {
 	//(2) At each slot, at most one rack is dispatched
  	forall( t in Slots) sum( j in Racks) x[j][t] <= 1;
  	
  	//(3) At each slot, at most C orders are under processing
  	forall( t in Slots) sum( i in Orders ) y[i][t] <= C;
  	
  	//(4) Each order is processed in consecutive slots, where  t, tpp, tp
  	// 0,0,0 <- no processing; 0, 0.x, 0.w or 0,0.x,1 or 0,1,1 <- start processing
  	// 1,1,1 <- processing and filled
  	// 1,1,0 or 1,0,0 <- completed
  	// t -tpp <= tpp-tp + 1     (tpp-t)  + 1 >=  (tp-tpp)     
  	forall( i in Orders )	
  		forall( t, tp, tpp in Slots )
  		    if( t < tpp < tp ) y[i][t] + y[i][tp] <= 1 + y[i][tpp];
  	
//    	forall( i in Orders )	
//  		forall( t, tp, tpp in Slots ) !( y[i][t] == 1 && y[i][tp] == 1 && y[i][tpp] == 0);
  			    
  	//(5) Each order must have its SKUS filled ( ? yet sum of z on order i should be the count of SKUs of order i)
  	forall( i in Orders, s in SKUInOrder[i] )
  	     sum( t in Slots ) z[s][i][t] >= 1;
  	     
  	//(6) 
  	forall( i in Orders, s in SKUInOrder[i], t in Slots )
  	     2 * z[s][i][t] <= y[i][t] + sum( j in RackHostSKU[s]) x[j][t];
  	         
  	//(7) 
  	forall( t in 2..T, j in Racks)
  	      alpha[t] >= x[j][t] - x[j][t-1];
  	
  	//(10)
  	//forall( t in Slots, i in Orders )
  	 //     y[i][t] <= 1;
  	
 }
 
 
/* 
Default Problem Best solution

Alpha
0 0 0 0 0 0 1 0 0 0 0 1

X (racks)
1 1 0 0 0 0 0 0 0 0 0 0 <-r1 (AC)
0 0 0 0 0 0 1 1 0 0 0 0 <-r2 (BD)
0 0 0 0 0 0 0 0 0 0 0 1 <-r3 (CD)

Y (orders)
1 1 1 1 1 1 1 0 0 0 0 0 <-o1 (ABC)
1 1 1 1 1 1 1 1 1 0 0 0 <-o2 (ABCD)
0 0 0 0 0 0 0 1 1 1 1 1 <-o3 (BCD)
0 0 0 0 0 0 0 0 0 0 0 1 <-o4 (CD)

Z ("A")
0 1 0 0 0 0 0 0 0 0 0 0 <-o1 (ABC)
0 1 0 0 0 0 0 0 0 0 0 0 <-o2 (ABCD)
0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 0 0 0 0

Z ("B")
0 0 0 0 0 0 1 0 0 0 0 0 <-o1 (ABC)
0 0 0 0 0 0 0 1 0 0 0 0 <-o2 (ABCD)
0 0 0 0 0 0 0 1 0 0 0 0 <-o3 (BCD)
0 0 0 0 0 0 0 0 0 0 0 0

Z ("C")
1 0 0 0 0 0 0 0 0 0 0 0 <-o1 (ABC)
1 0 0 0 0 0 0 0 0 0 0 0 <-o2 (ABCD)
0 0 0 0 0 0 0 0 0 0 0 1 <-o3 (BCD)
0 0 0 0 0 0 0 0 0 0 0 1 <-o4 (CD)

Z ("D")
0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 1 0 0 0 0 <-o2 (ABCD)
0 0 0 0 0 0 0 1 0 0 0 0 <-o3 (BCD)
0 0 0 0 0 0 0 0 0 0 0 1 <-o4 (CD)
*/