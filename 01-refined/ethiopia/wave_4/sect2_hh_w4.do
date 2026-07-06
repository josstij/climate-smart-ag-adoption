* Project: lsms gender
* Created on: 3 nov 2025
* Created by: jt
* Edited on: 6 now 2025
* Edited by: jt
* Stata v.19.5

* does
	* inputs wave4 dataset for indv edu data
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
	global	root 	"$data/raw_lsms_data/ethiopia/wave_4/raw"
	global	export 	"$data/lsms_gender_data/01-refined_data/ethiopia/wave_4"
	global	logout 	"$data/lsms_gender_data/01-refined_data/ethiopia/logs"

* open log 
	cap		log		close
	log		using	"$logout/sect2_hh_w4", append
	

************************************************************************
**# 1 - clean data
************************************************************************

* load data
		use			"$root/sect2_hh_w4", clear

* rename variables
	rename		(saq01 saq02 saq03 saq04 saq05 saq06 saq07 saq08 s2q06) ///
					(admin_1 admin_2 admin_3 admin_4 admin_5 admin_6 ///
					ea household_num edu)
	
* relabel read/write
	replace		edu = 98 if s2q03 == 2
	
	
* keep essential variables
 	keep		household_id individual_id ea_id admin_1 admin_2 admin_3 ///
				admin_4 admin_5 admin_6 ea household_num edu

		
************************************************************************
**# 2 - end matter
************************************************************************

* save file
	qui: 			compress
	isid		    household_id individual_id 
	save 			"$export/sect2_hh_w4", replace
	
* close the log
	log	close

/* END */