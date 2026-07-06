* Project: lsms gender dynamics
* Created on: June 2025
* Created by: george hyland, jared sage
* Edited on: 24 March 2026
* Edited by: alj, jared
* Stata v.19.5

* does
	* cleans dataset for hh panel
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
	log using "$logout/hh_mod_b_16", append


************************************************************************
**# 1 - clean data
************************************************************************

* load data
		use			"$root/hh_mod_b_16", clear
		
* check for unique var
		isid		PID	y3_hhid

* merge data
		merge		1:1 PID using "$root/hh_mod_c_16"
		
		drop		_merge
		
		merge		1:1 PID using "$root/hh_mod_e_16"
		
		drop		_merge
		
/*		
	Result                      Number of obs
    -----------------------------------------
    Not matched                             0
    Matched                            12,266  (_merge==3)
    -----------------------------------------
*/

* rename variables
		rename		hh_b03 		sex
		rename		hh_c09 		edu
		rename		hh_b05a 	age
		rename		hh_b04 		relate
		rename		hh_b24		mrry
		rename		hh_e06_4	wage
		rename		hh_e06_2	nfe
		rename		hh_e06_1a	farm
		rename		PID			indiv_num
				
* replace edu
	replace		edu = 0 if edu == . & (hh_c05a == 2 | hh_c06 == 2)
		
	keep		y3_hhid indiv_num sex edu age relate mrry wage nfe farm
		
* destring indiv

* Extract the last two digits of the long PID string (e.g. "000102" becomes "02")
	gen 		str_indiv = substr(indiv_num, -2, 2)

* Destring it into a pure number (e.g. "02" becomes 2)
	destring 	str_indiv, generate(indiv)

* Clean up
	drop 		str_indiv
		
* drop individuals with no valid ID
	drop if 	missing(indiv)	
	
	duplicates 	tag y3_hhid indiv, gen(dup)
	drop if 	dup > 0 & relate != 1
	drop 		dup
	
	
************************************************************************
**# 2 - end matter
************************************************************************

* Identify any duplicates created by slicing the PID
	duplicates 	tag y3_hhid indiv, gen(dup)

* Drop the duplicate that isn't the household head (relate == 1) to force uniqueness
	drop if 	dup > 0 & relate != 1 
		
	drop 		dup

* save file
	isid			y3_hhid indiv
	qui: 			compress
	save 			"$export/hh_mod_b_16_w3", replace
	
* close the log
	log	close

/* END */
