* Project: lsms gender
* Created on: 3 nov 2025
* Created by: jt
* Edited on: 24 nov 2025
* Edited by: jt
* Stata v.19.5

* does
	* inputs wave5 dataset for hh indv data
	* cleans up indv lvl variables 
	* outputs file containing indv_id, relation to hoh, sex, age, away
		
* assumes
	* access to raw data 

* TO DO:
	* almost done
	* needs HH member ID code
	

************************************************************************
**# 0 - setup
************************************************************************

* define paths
	global	root 	"$data/raw_lsms_data/ethiopia/wave_5/raw"
	global	export 	"$data/lsms_gender_data/01-refined_data/ethiopia/wave_5"
	global	logout 	"$data/lsms_gender_data/01-refined_data/ethiopia/logs"
	
* open log 
	cap		log		close
	log		using	"$logout/sect1_hh_w5", append
	

************************************************************************
**# 1 - clean data
************************************************************************

* load data
		use			"$root/sect1_hh_w5", clear

* inspect roster identifiers
	describe	household_id individual_id

	isid		household_id individual_id
	duplicates report household_id individual_id
	
* rename variables
	rename		(s1q01 s1q02 s1q03a s1q06 s1q09) ///
					(relat sex age away mrry)
	
* create household size
	bysort		household_id: ///
		gen		hhsize = _N

* verify household-size distribution
	egen		hh_tag = tag(household_id)

	tabstat		hhsize if hh_tag, ///
					statistics(n mean p50 min max)
					
* keep essential variables
	keep		household_id individual_id ea_id ///
				relat sex age away mrry hhsize

		
************************************************************************
**# 2 - end matter
************************************************************************

* save file
	qui: 			compress
	isid			household_id individual_id
	save 			"$export/sect1_hh_w5", replace
	
* close the log
	log	close

/* END */