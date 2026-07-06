* Project: lsms gender dynamics
* Created on: June 2025
* Created by: george hyland, jared sage
* Edited on: 24 March 2026
* Edited by: alj, jared
* Stata v.19.5

* does
	* cleans dataset for hh panel
	* merges hh_mod_b_13 & hh_mod_c_13
		
* assumes
	* access to raw data 

* TO DO:
	* done!

************************************************************************
**# 0 - setup
************************************************************************

* define paths
	global root 	"$data/raw_lsms_data/malawi/harmonized/wave_2"
	global export 	"$data/lsms_gender_data/01-refined_data/malawi/wave_2"
	global logout 	"$data/lsms_gender_data/01-refined_data/malawi/logs"
	
* open log 
	cap log close
	log using "$logout/hh_mod_b_13_w2", append


************************************************************************
**# 1 - clean data
************************************************************************

* load data
		use			"$root/hh_mod_b_13", clear
		
* check for unique var
		isid		hh_b01 y2_hhid
		
		rename		hh_b01		hh_c01

* merge data
		merge		1:1 hh_c01 y2_hhid using "$root/hh_mod_c_13"
		
* rename variables
		rename		hh_b05a 	age
		rename		hh_c09 		edu
		rename		hh_c01		hh_e01
* replace edu for 5+
		replace 	edu = 0 if edu == . & age > 4 & _merge == 1
	
		drop		_merge
		
		merge		1:1 hh_e01 y2_hhid using "$root/hh_mod_e_13"
		
* rename variables
		rename		hh_e06_4	wage
		rename		hh_e06_2	nfe
		rename		hh_e06_1	farm
		rename		hh_e01		indiv
		
* replace work for 5+
		replace 	wage = 0 if wage == . & age > 4 & _merge == 1
		replace 	farm = 0 if farm == . & age > 4 & _merge == 1
		replace 	nfe = 0 if nfe == . & age > 4 & _merge == 1
		
		
		drop		_merge
		
/*		Result                      Number of obs
     -----------------------------------------
    Not matched                             0
    Matched                            10,035  (_merge==3)
    -----------------------------------------

*/

* rename variables
		rename		hh_b03 		sex
		rename		hh_b04 		relate
		rename		hh_b24		mrry
		
 		keep		y2_hhid 	indiv sex edu age relate mrry wage nfe farm


************************************************************************
**# 2 - end matter
************************************************************************

* save file
	isid			y2_hhid indiv
	qui: 			compress
	save 			"$export/hh_mod_b_13_w2", replace
	
* close the log
	log				close

/* END */
