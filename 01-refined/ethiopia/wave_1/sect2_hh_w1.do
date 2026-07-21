* Project: lsms gender
* Created on: 3 nov 2025
* Created by: jt
* Edited on: 10 nov 2025
* Edited by: jt
* Stata v.19.5

* does
	* inputs wave1 dataset for indv edu data
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
	global	root 	"$data/raw_lsms_data/ethiopia/wave_1/raw"
	global	export 	"$data/lsms_gender_data/01-refined_data/ethiopia/wave_1"
	global	logout 	"$data/lsms_gender_data/01-refined_data/ethiopia/logs"
	
* open log 
	cap		log		close
	log		using	"$logout/sect2_hh_w1", append
	

************************************************************************
**# 1 - clean data
************************************************************************

* load data
		use			"$root/sect2_hh_w1", clear

* rename variables
	rename		( hh_s2q05 saq01 saq02 saq03 saq04 saq05 saq06 ///
					saq07 ) ///
				( edu admin_1 admin_2 admin_3 admin_4 admin_5 ///
						admin_6 ea )
	
* relabel read/write
	replace		edu = 98 if hh_s2q02 == 2
	
	
* keep essential variables
 	keep		individual_id household_id ea_id admin_1 admin_2 admin_3 ///
					admin_4 admin_5 admin_6 ea edu

		
************************************************************************
**# 2 - end matter
************************************************************************

* save file
	qui: 			compress
	isid			individual_id
	save 			"$export/sect2_hh_w1", replace
	
* close the log
	log	close

/* END */