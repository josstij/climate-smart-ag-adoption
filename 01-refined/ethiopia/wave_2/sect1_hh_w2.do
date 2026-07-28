* Project: lsms gender
* Created on: 3 nov 2025
* Created by: jt
* Edited on: 27 july 2026
* Edited by: jt
* Stata v.19.5

* does
	* inputs wave2 dataset for hh indv data
	* cleans up indv lvl variables 
	* outputs file containing indv_id, relation to hoh, sex, age, away
		
* assumes
	* access to raw data 

* TO DO:
	* DONE !!
	

************************************************************************
**# 0 - setup
************************************************************************

* define paths
	global	root 	"$data/raw_lsms_data/ethiopia/wave_2/raw"
	global	export 	"$data/lsms_gender_data/01-refined_data/ethiopia/wave_2"
	global	logout 	"$data/lsms_gender_data/01-refined_data/ethiopia/logs"
	
* open log 
	cap		log		close
	log		using	"$logout/sect1_hh_w2", append
	

************************************************************************
**# 1 - clean data
************************************************************************

* load data
		use			"$root/sect1_hh_w2", clear

* rename variables
	rename		(hh_s1q00 hh_s1q02 hh_s1q03 hh_s1q04_a hh_s1q05 hh_s1q08) ///
					(indiv_num relat sex age away mrry)
					
* create household size
	bysort		household_id2: ///
		gen		hhsize = _N

* label variable
	lab var		hhsize "household size"
	
* keep essential variables
 	keep		household_id household_id2 individual_id individual_id2 ///
				ea_id ea_id2 indiv_num relat sex age away mrry hhsize

		
************************************************************************
**# 2 - end matter
************************************************************************

* save file
	qui: 			compress
	isid			individual_id2 
	save 			"$export/sect1_hh_w2", replace
	
* close the log
	log	close

/* END */