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
	global root 	"$data/raw_lsms_data/malawi/harmonized/wave_1"
	global export 	"$data/lsms_gender_data/01-refined_data/malawi/wave_1"
	global logout 	"$data/lsms_gender_data/01-refined_data/malawi/logs"
	
* open log 
	cap log close
	log using "$logout/ag_mod_d_10", append

************************************************************************
**# 1 - clean data
************************************************************************

* load data
	use			"$root/ag_mod_d_10", clear

* rename variables
	rename			ag_d01 		mgmt1
	rename			ag_d03		tenure
	rename			ag_d04a		defa1
	rename			ag_d04b		defa2
	rename			ag_d00		plotid
* keep essential variables
 	keep			HHID case_id plotid mgmt1 tenure defa1 defa2
	
	
************************************************************************
**## 2 - fill in missing defa 1-4 (Waterfall logic)
************************************************************************

* shift defa2 left
	replace		defa1 = defa2 if defa1 == .
	replace		defa2 = . if defa1 == defa2


************************************************************************
**# 3 - end matter
************************************************************************

* drop observations where the IDs are missing
	drop if 		mi(case_id) | mi(plotid)

* check uniqueness again
	isid 			case_id plotid

* save file
	isid			case_id plotid
	qui: 			compress
	save 			"$export/ag_mod_d_10_w1", replace
	
* close the log
	log	close

/* END */
