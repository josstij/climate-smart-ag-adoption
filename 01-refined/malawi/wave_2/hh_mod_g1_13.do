* Project: lsms gender dynamics
* Created on: July 2025
* Created by: george hyland
* Edited on: 16 July 2025
* Edited by: george hyland
* Stata v.19.5

* does
		* cleans data for hh food consumption
		* keeps foods hh consumes & produces, excludes purchases
		
* assumes

* to do
		* convert unit codes into strings

		
************************************************************************
**# 0 - setup
************************************************************************

* define paths
	global root 	"$data/raw_lsms_data/malawi/harmonized/wave_2"
	global export 	"$data/lsms_gender_data/01-refined_data/malawi/wave_2"
	global logout 	"$data/lsms_gender_data/01-refined_data/malawi/logs"

* open log 
	cap log close 
	log using "$logout/hh_mod_g1_13", append
	
	
************************************************************************
**# 1 - clean data
************************************************************************

* load data
		use			"$root/hh_mod_g1_13", clear
		
* rename variables
		rename (hh_g02 hh_g06a hh_g06b) (item prd_qty prd_unit)
		
* drop foods not consumed/produced by hh
		decode hh_g01, gen(consumed)
		drop if consumed == "NO"
		drop if prd_qty == .
		drop if prd_qty == 0
		
* keep relevant variables
		keep y2_hhid item prd_qty prd_unit
		
		
************************************************************************
**# 2 - end matter
************************************************************************

* save file
	//isid			PID
	qui: 			compress
	save 			"$export/hh_g1_13", replace
	
* close the log
	log	close

/* END */
