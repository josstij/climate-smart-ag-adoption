* Project: lsms gender
* Created on: 10 nov 2025
* Created by: jt
* Edited on: 10 nov 2025
* Edited by: jt
* Stata v.19.5

* does
	* inputs wave5 dataset for indv labor data
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
	global	root 	"$data/raw_lsms_data/ethiopia/wave_5/raw"
	global	export 	"$data/lsms_gender_data/01-refined_data/ethiopia/wave_5"
	global	logout 	"$data/lsms_gender_data/01-refined_data/ethiopia/logs"
	
* open log 
	cap		log		close
	log		using	"$logout/sect4_hh_w5", append
	

************************************************************************
**# 1 - clean data
************************************************************************

* load data
		use			"$root/sect4_hh_w5", clear
		
* inspect Wave 5 labor questions
	describe	s4q05 s4q08 s4q12

	codebook	s4q05 s4q08 s4q12
* create individual farm-work indicator
	gen			farm = .
	replace		farm = 1 if s4q05 == 1
	replace		farm = 0 if s4q05 == 2

	lab var		farm ///
					"did agricultural work for household last 7 days"

* create individual nonfarm-enterprise indicator
	gen			nfe = .
	replace		nfe = 1 if s4q08 == 1
	replace		nfe = 0 if s4q08 == 2

	lab var		nfe ///
					"worked on own account or in household enterprise last 7 days"

* create individual paid-work indicator
	gen			wage = .
	replace		wage = 1 if s4q12 == 1
	replace		wage = 0 if s4q12 == 2

	lab var		wage ///
					"worked for payment during last 7 days"

* create household-level nonfarm-enterprise indicator
	bysort		household_id: ///
		egen	hh_nfe = max(nfe)

* create nonfarm-enterprise barrier
	gen			no_nfe = .
	replace		no_nfe = 0 if hh_nfe == 1
	replace		no_nfe = 1 if hh_nfe == 0

	lab define	barrier01 ///
					0 "no barrier" ///
					1 "barrier", replace

	lab var		no_nfe ///
					"no household member worked in household enterprise last 7 days"

	lab values	no_nfe barrier01

* verify once per household
	egen		hh_tag = tag(household_id)

	tab			hh_nfe if hh_tag, missing
	tab			no_nfe if hh_tag, missing
	
* rename individual number
	rename			(saq08) ///
					(indiv_num)
	
* keep essential variables
	keep		individual_id household_id ea_id indiv_num ///
				farm nfe wage hh_nfe no_nfe


		
************************************************************************
**# 2 - end matter
************************************************************************

* save file
	qui: 			compress
	isid			household_id individual_id
	save 			"$export/sect4_hh_w5", replace
	
* close the log
	log	close

/* END */