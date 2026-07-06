* Project: lsms gender dynamics
* Created on: march 2026
* Created by: jared sage
* Edited on: 3 March 2026
* Edited by: jared
* Stata v.19.5

* does
		* cleans dataset for 2010 ag panel
		* cleans up gendered plot variables 
		
* assumes
	* access to raw data 

* TO DO:
	* done!

************************************************************************
**# 0 - setup
************************************************************************

* define paths
	global root 	"$data/raw_lsms_data/malawi/harmonized/wave_3"
	global export 	"$data/lsms_gender_data/01-refined_data/malawi/wave_3"
	global logout 	"$data/lsms_gender_data/01-refined_data/malawi/logs"
	
* open log 
	cap log close
	log using "$logout/ag_mod_d_16_w3", append

************************************************************************
**# 1 - clean data
************************************************************************

* load data
		use			"$root/ag_mod_d_16", clear

* rename variables
		gen			mgmt1	=	ag_d01 		
		gen			mgmt2	=	ag_d01_2a	
		gen			mgmt3	=	ag_d01_2b	

* label variables
		forvalues 	i = 1/3 {
			
		lab var 	mgmt`i' "WHO IN THE HH MANAGES THIS [PLOT]? (ID CODE 1)"
		
	}
	
* replace ID 0 with missing since no indiv = 0
		forvalues 	i = 1/3 {
			
		replace 	mgmt`i' = . if mgmt`i' == 0
		
	}
	
* keep essential variables
 		keep		y3_hhid plotid gardenid mgmt1 mgmt2 mgmt3

************************************************************************
**# 2 - end matter
************************************************************************

*drop if missing 
	drop if 		missing(y3_hhid) | missing(gardenid) | missing(plotid)

* save file
	isid			y3_hhid	plotid gardenid
	qui: 			compress
	save 			"$export/ag_mod_d_16_w3", replace
	
* close the log
	log	close

/* END */
