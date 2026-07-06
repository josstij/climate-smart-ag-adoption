* Project: lsms gender dynamics
* Created on: June 2025
* Created by: george hyland
* Edited on: 23 july 2025
* Edited by: alj
* Stata v.19.5

* does
		* cleans dataset for IHS4 hh panel
		* merges hh_mod_b_16 & hh_mod_c_16
		
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
	log using "$logout/ag_mod_b_16", append


************************************************************************
**# 1 - clean data
************************************************************************

* load data
		use			"$root/hh_mod_b_16", clear
		
* check for unique var
		isid		PID

* merge data
		merge		1:1 PID using "$root/hh_mod_c_16"

		drop		_merge
		
/*		Result                      Number of obs
    -----------------------------------------
    Not matched                             0
    Matched                            12,266  (_merge==3)
    -----------------------------------------

*/

* rename variables
		rename		hh_b03 sex
		rename		hh_c09 edu
		rename		hh_b05a age
		rename		hh_b04 relate
		
		
* keep relevant variables
 		keep		y3_hhid i_HHID PID sex edu age relate


************************************************************************
**# 2 - end matter
************************************************************************

* save file
	isid			PID
	qui: 			compress
	save 			"$export/hh_b_16", replace
	
* close the log
	log	close

/* END */