* Project: lsms gender
* Created on: 3 nov 2025
* Created by: jt
* Edited on: 27 july 2026
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

* identify household participation in a nonfarm enterprise
	bysort		household_id: ///
		egen	hh_nfe = max(nfe)

* create nonfarm-enterprise barrier
	gen			no_nfe = .
	replace		no_nfe = 0 if hh_nfe == 1
	replace		no_nfe = 1 if hh_nfe == 0

* label variables
	lab var		hh_nfe "any household member worked in household nonfarm business"
	lab var		no_nfe "no household member worked in household nonfarm business"

	lab values	no_nfe barrier01
	
	egen		hh_tag = tag(household_id)

	tab			hh_nfe if hh_tag, missing
	tab			no_nfe if hh_tag, missing

* keep essential variables
	keep		individual_id household_id ea_id indiv_num ///
				farm nfe wage hh_nfe no_nfe
				
				
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