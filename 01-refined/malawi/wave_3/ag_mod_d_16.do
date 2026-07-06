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
	log using "$logout/ag_mod_d_16", append

************************************************************************
**# 1 - clean data
************************************************************************

* load data
		use			"$root/ag_mod_d_16", clear

* rename variables
		rename			ag_d01 		mgmt1
		rename			ag_d01_2a	mgmt2
		rename			ag_d01_2b	mgmt3
		
		
* keep essential variables
 		keep		mgmt1 mgmt2 mgmt3

************************************************************************
**# 2 - end matter
************************************************************************

* save file
	qui: 			compress
	save 			"$export/ag_mod_d_16", replace
	
* close the log
	log	close

/* END */
