* Project: lsms gender dynamics
* Created on: march 2026
* Created by: jared sage
* Edited on: 17 March 2026
* Edited by: jared
* Stata v.19.5

* does
		* cleans dataset for 2010 hh panel
		* cleans up gendered plot variables 
		
* assumes
	* access to raw data 

* TO DO:
	* done!

************************************************************************
**# 0 - setup
************************************************************************

* define paths
	global root 	"$data/raw_lsms_data/malawi/harmonized/wave_1"
	global export 	"$data/lsms_gender_data/01-refined_data/malawi/wave_1"
	global logout 	"$data/lsms_gender_data/01-refined_data/malawi/logs"
	
* open log 
	cap log close
	log using "$logout/hh_mod_e_10", append

************************************************************************
**# 1 - clean data
************************************************************************

* load data
		use			"$root/hh_mod_e_10", clear
		
* rename variables
	rename			hh_e60 		wage
	rename			hh_e07		farm
	rename			hh_e08		nfe			
* keep essential variables
 		keep		HHID PID wage farm nfe

************************************************************************
**# 2 - end matter
************************************************************************

* save file
	qui: 			compress
	save 			"$export/hh_mod_e_10", replace
	
* close the log
	log	close

/* END */
