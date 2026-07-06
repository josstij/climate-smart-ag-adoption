* Project: lsms gender
* Created on: 3 nov 2025
* Created by: jt
* Edited on: 7 april 26
* Edited by: jt
* Stata v.19.5

* does
	* inputs wave4 dataset for hh indv data
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
	global	root 	"$data/raw_lsms_data/ethiopia/wave_4/raw"
	global	export 	"$data/lsms_gender_data/01-refined_data/ethiopia/wave_4"
	global	logout 	"$data/lsms_gender_data/01-refined_data/ethiopia/logs"
	
* open log 
	cap		log		close
	log		using	"$logout/sect1_hh_w4", append
	

************************************************************************
**# 1 - clean data
************************************************************************

* load data
		use			"$root/sect1_hh_w4", clear

* rename variables
	rename		(s1q01 s1q02 s1q03a s1q06 s1q09) ///
					(relat sex age away mrry)
	
* keep essential variables
 	keep		household_id ea_id relat individual_id ///
					sex age away mrry

		
************************************************************************
**# 2 - end matter
************************************************************************

* save file
	qui: 			compress
	isid			household_id individual_id 
	save 			"$export/sect1_hh_w4", replace
	
* close the log
	log	close

/* END */