/* BEGIN */

* Project: lsms gender dynamics
* Created on: June 2025
* Created by: george hyland
* Edited on: 23 july 2025
* Edited by: alj
* Stata v.19.5

* does
		* cleans dataset for IHS4 hh panel
		* merges hh_mod_b_19 & hh_mod_c_19
		
* assumes
	* access to raw data 

* TO DO:
	* done!
/*		
************************************************************************
**# 0 - setup
************************************************************************

* define paths
	global root 	"$data/MWI_2010-2019_IHPS_v06_M_Stata"
	global export 	"$data/refined/wave_4"
	global logout 	"$data/log"

* open log 
	cap log close 
	log using "$logout/mwi_wth_p", append


************************************************************************
**# 1 - clean data
************************************************************************

* load data
		use			"$root/hh_mod_b_19", clear
		
* check for unique var
		isid		PID

* merge data
		merge		1:1 PID using "$root/hh_mod_c_19"

		drop		_merge
		
/*		Result                      Number of obs
    -----------------------------------------
    Not matched                             0
    Matched                            14,649  (_merge==3)
    -----------------------------------------

*/

* rename variables
		rename		hh_b03 sex
		rename		hh_c09 edu
		rename		hh_b05a age
		rename		hh_b04 relate
		
 		keep		y4_hhid PID sex edu age relate


************************************************************************
**# 2 - end matter
************************************************************************

* save file
	isid			PID
	qui: 			compress
	save 			"$export/hh_sec_19", replace
	
* close the log
	log	close

/* END */