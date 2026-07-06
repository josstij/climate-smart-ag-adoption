* Project: lsms gender
* Created on: 3 nov 2025
* Created by: jt
* Edited on: 10 nov 2025
* Edited by: jt
* Stata v.19.5

* does
	* inputs wave1 dataset for hh indv labor data
	* cleans up indv lvl variables 
	* outputs file containing farm, wages, nfe
		
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
	log		using	"$logout/sect4_hh_w1", append
	

************************************************************************
**# 1 - clean data
************************************************************************

* load data
		use			"$root/sect4_hh_w1", clear

* create labor variables
	gen				farm = 1 if hh_s4q04 > 0 & hh_s4q04 != .
	replace			farm = 0 if hh_s4q04 == 0
	lab var			farm "works on farm"
	
	gen				nfe = 1 if hh_s4q05 > 0 & hh_s4q05 != .
	replace			nfe = 0 if hh_s4q05 == 0
	lab var			nfe "works for nfe"
	
	gen				wage = 1 if hh_s4q07 > 0 & hh_s4q07 != . 
	replace			wage = 0 if hh_s4q07 == 0
	lab var			wage "works for wages"
	
* rename individual number
	rename			hh_s4q00 indiv_num
	
* keep essential variables
 	keep		individual_id household_id ea_id indiv_num farm nfe wage

		
************************************************************************
**# 2 - end matter
************************************************************************

* save file
	qui: 			compress
	isid			individual_id
	save 			"$export/sect4_hh_w1", replace
	
* close the log
	log	close

/* END */