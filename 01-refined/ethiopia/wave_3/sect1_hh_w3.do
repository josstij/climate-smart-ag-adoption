* Project: lsms gender
* Created on: 3 nov 2025
* Created by: jt
* Edited on: 3 april 2026
* Edited by: jt
* Stata v.19.5

* does
	* inputs wave3 dataset for hh indv data
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
	global	root 	"$data/raw_lsms_data/ethiopia/wave_3/raw"
	global	export 	"$data/lsms_gender_data/01-refined_data/ethiopia/wave_3"
	global	logout 	"$data/lsms_gender_data/01-refined_data/ethiopia/logs"
	
* open log 
	cap		log		close
	log		using	"$logout/sect1_hh_w3", append
	

************************************************************************
**# 1 - clean data
************************************************************************

* load data
	use			"$root/sect1_hh_w3", clear

* rename variables
	rename		(hh_s1q00 hh_s1q02 hh_s1q03 hh_s1q04a hh_s1q05 hh_s1q08) ///
					(indiv_num relat sex age away mrry)
	
* keep essential variables
 	keep		household_id individual_id ///
					ea_id ea_id2 indiv_num relat sex age away mrry

	duplicates drop household_id individual_id, force	
************************************************************************
**# 2 - end matter
************************************************************************

* save file
	qui: 			compress
	isid			household_id individual_id
	save 			"$export/sect1_hh_w3", replace
	
* close the log
	log	close

/* END */