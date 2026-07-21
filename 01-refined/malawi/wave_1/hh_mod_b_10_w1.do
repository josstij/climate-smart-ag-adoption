* Project: lsms gender dynamics
* Created on: June 2025
* Created by: jared sage
* Edited on: 24 March 2026
* Edited by:  jared
* Stata v.19.5

* does
	* cleans dataset for hh panel
	
		
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
	log using "$logout/hh_mod_b_10", append


************************************************************************
**# 1 - clean data
************************************************************************

* load data
		use			"$root/hh_mod_b_10", clear
		
* check for unique var
		isid		PID


* rename variables
		rename		hh_b03 		sex
		rename		hh_b05a 	age
		rename		hh_b04 		relate
		rename		hh_b24		mrry
		
 		keep		case_id id_code HHID PID sex age relate mrry 


************************************************************************
**# 2 - end matter
************************************************************************

* save file
	isid			case_id id_code
	qui: 			compress
	save 			"$export/hh_mod_b_10_w1", replace
	
* close the log
	log	close

/* END */
