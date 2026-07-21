* Project: lsms gender
* Created on: 10 nov 2025
* Created by: jt
* Edited on: 10 nov 2025
* Edited by: jt
* Stata v.19.5

* does
	* inputs wave4 dataset for indv labor data
	* cleans up indv lvl labor variables 
	* outputs file containing farm, nfe, wage
		
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
	log		using	"$logout/sect4_hh_w4", append
	

************************************************************************
**# 1 - clean data
************************************************************************

* load data
		use			"$root/sect4_hh_w4", clear

* create labor variables
	gen				farm = 1 if s4q06 > 0 & s4q06 != .
	replace			farm = 0 if s4q06 == 0
	lab var			farm "works on farm"
	
	gen				nfe = 1 if s4q08 > 0 & s4q08 != .
	replace			nfe = 0 if s4q08 == 0
	lab var			nfe "works for nfe"
	
	gen				wage = 1 if s4q10 > 0 & s4q10 != . 
	replace			wage = 0 if s4q10 == 0
	lab var			wage "works for wages"
	
* rename individual number
	rename			(saq08) ///
					(indiv_num)
	
* keep essential variables
 	keep		individual_id household_id ea_id ///
				 indiv_num farm nfe wage


		
************************************************************************
**# 2 - end matter
************************************************************************

* save file
	qui: 			compress
	isid			household_id individual_id
	save 			"$export/sect4_hh_w4", replace
	
* close the log
	log	close

/* END */