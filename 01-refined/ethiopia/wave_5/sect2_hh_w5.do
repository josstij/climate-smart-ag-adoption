* Project: lsms gender
* Created on: 3 nov 2025
* Created by: jt
* Edited on: 6 now 2025
* Edited by: jt
* Stata v.19.5

* does
	* inputs wave5 dataset for indv edu data
	* cleans up indv lvl edu variables 
	* outputs file containing indv_id, edu
		
* assumes
	* access to raw data 

* TO DO:
	* DONE !!
	

************************************************************************
**# 0 - setup
************************************************************************

* define paths
	global	root 	"$data/raw_lsms_data/ethiopia/wave_5/raw"
	global	export 	"$data/lsms_gender_data/01-refined_data/ethiopia/wave_5"
	global	logout 	"$data/lsms_gender_data/01-refined_data/ethiopia/logs"
	
* open log 
	cap		log		close
	log		using	"$logout/sect2_hh_w5", append
	

************************************************************************
**# 1 - clean data
************************************************************************

* load data
		use			"$root/sect2_hh_w5", clear

* rename variables
	rename		 (s2q06 saq08) ///
					(edu household_num)
	
* relabel read/write
	replace		edu = 98 if s2q03 == 2
	
	
* keep essential variables
 	keep		household_id individual_id household_num ///
			    ea_id edu

		
************************************************************************
**# 2 - end matter
************************************************************************

* save file
	qui: 			compress
	isid			household_id individual_id 
	save 			"$export/sect2_hh_w5", replace
	
* close the log
	log	close

/* END */