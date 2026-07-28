* Project: lsms gender
* Created on: 10 nov 2025
* Created by: jt
* Edited on: 3 april 2026
* Edited by: jt
* Stata v.19.5

* does
	* inputs wave3 dataset for indv labor data
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
	global	root 	"$data/raw_lsms_data/ethiopia/wave_3/raw"
	global	export 	"$data/lsms_gender_data/01-refined_data/ethiopia/wave_3"
	global	logout 	"$data/lsms_gender_data/01-refined_data/ethiopia/logs"
	
* open log 
	cap		log		close
	log		using	"$logout/sect4_hh_w3", append
	

************************************************************************
**# 1 - clean data
************************************************************************

* load data
		use			"$root/sect4_hh_w3", clear
		
		codebook		hh_s4q05

		tab			hh_s4q05, missing

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
	
* remove duplicate individual records
	duplicates drop household_id individual_id, force
	
* identify household participation in a nonfarm enterprise
	bysort		household_id: ///
		egen	hh_nfe = max(nfe)

* create nonfarm-enterprise barrier
	gen			no_nfe = .
	replace		no_nfe = 0 if hh_nfe == 1
	replace		no_nfe = 1 if hh_nfe == 0

* label variables
	lab var		hh_nfe ///
					"any household member worked in household nonfarm business"
	lab var		no_nfe ///
					"no household member worked in household nonfarm business"

* define and apply barrier value label
	lab define	barrier01 ///
					0 "no barrier" ///
					1 "barrier", replace

	lab values	no_nfe barrier01

* verify once per household
	egen		hh_tag = tag(household_id)

	tab			hh_nfe if hh_tag, missing
	tab			no_nfe if hh_tag, missing
	
* keep essential variables
	keep		individual_id household_id ea_id ///
				ea_id2 indiv_num farm nfe wage ///
				hh_nfe no_nfe	
	
	
************************************************************************
**# 2 - end matter
************************************************************************

* save file
	qui: 			compress
	isid			household_id individual_id
	save 			"$export/sect4_hh_w3", replace
	
* close the log
	log	close

/* END */