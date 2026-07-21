* Project: lsms gender
* Created on: 3 nov 2025
* Created by: jt
* Edited on: 3 now 2025
* Edited by: jt
* Stata v.19.5

* does
	* inputs wave2 dataset for indv edu data
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
	global	root 	"$data/raw_lsms_data/ethiopia/wave_2/raw"
	global	export 	"$data/lsms_gender_data/01-refined_data/ethiopia/wave_2"
	global	logout 	"$data/lsms_gender_data/01-refined_data/ethiopia/logs"
	
* open log 
	cap		log		close
	log		using	"$logout/sect2_hh_w2", append
	

************************************************************************
**# 1 - clean data
************************************************************************

* load data
		use			"$root/sect2_hh_w2", clear

* rename variables
	rename		(hh_s2q00 hh_s2q05 saq01 saq02 saq03 saq04 saq05 saq06 ///
					saq07 saq08) ///
				(indiv_num edu admin_1 admin_2 admin_3 admin_4 admin_5 ///
					admin_6 ea household_num)
	
* relabel read/write
	replace		edu = 98 if hh_s2q02 == 2
	
* keep essential variables
 	keep		individual_id individual_id2 household_id household_id2 ///
					ea_id admin_1 admin_2 admin_3 admin_4 admin_5 admin_6 ea ///
					household_num indiv_num edu

		
************************************************************************
**# 2 - end matter
************************************************************************

* save file
	qui: 			compress
	isid			individual_id2 household_id2
	save 			"$export/sect2_hh_w2", replace
	
* close the log
	log	close

/* END */