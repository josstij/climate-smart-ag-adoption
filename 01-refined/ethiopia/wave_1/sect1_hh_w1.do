* Project: lsms gender
* Created on: 3 nov 2025
* Created by: jt
* Edited on: 3 now 2025
* Edited by: jt
* Stata v.19.5

* does
	* inputs wave1 dataset for hh indv data
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
	global	root 	"$data/raw_lsms_data/ethiopia/wave_1/raw"
	global	export 	"$data/lsms_gender_data/01-refined_data/ethiopia/wave_1"
	global	logout 	"$data/lsms_gender_data/01-refined_data/ethiopia/logs"
	
* open log 
	cap		log		close
	log		using	"$logout/sect1_hh_w1", append
	

************************************************************************
**# 1 - clean data
************************************************************************

* load data
		use			"$root/sect1_hh_w1", clear

* rename variables
	rename		(hh_s1q00 hh_s1q02 hh_s1q03 hh_s1q04_a hh_s1q05 hh_s1q08) ///
					(indiv_num relat sex age away mrry)
	
* keep essential variables
 	keep		individual_id household_id ea_id indiv_num relat sex age away mrry

		
************************************************************************
**# 2 - end matter
************************************************************************

* save file
	qui: 			compress
	isid			individual_id
	save 			"$export/sect1_hh_w1", replace
	
* close the log
	log	close

/* END */