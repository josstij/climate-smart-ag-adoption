* Project: lsms gender
* Created on: oct 2025
* Created by: jt
* Edited on: 27 july 2026
* Edited by: jt
* Stata v.19.5

* does
	* inputs wave1 dataset for post planting parcel ownership data
	* cleans up gendered parcel owner variables 
	* outputs file containing defacto owners, dejure owners, tenure
	* no collat, own1, own2, beqth
		
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
	log		using	"$logout/sect2_pp_w1", append
	

************************************************************************
**# 1 - clean data
************************************************************************

* load data
		use			"$root/sect2_pp_w1", clear

* rename variables
	rename		(pp_saq07 pp_s2q03 pp_s2q04 pp_s2q06_a pp_s2q06_b) ///
					(mgmt1 tenure title deju1 deju2)

* recode yes no
	replace		title = 0 if title == 2
	lab			define yesno 0 "no" 1 "yes"
	lab			value title yesno
	
	tab		title, missing
	
* create land-certification barrier
	gen			no_title = .
	replace		no_title = 0 if title == 1
	replace		no_title = 1 if title == 0

* label variable
	lab var		no_title "household does not have parcel certificate"

* apply barrier value label
	lab values	no_title barrier01

* verify construction
	tab			title no_title, missing
	
* create potential tenure-security barrier
	gen			insecure_tenure = .
	replace		insecure_tenure = 0 if inlist(tenure, 1, 2)
	replace		insecure_tenure = 1 if inlist(tenure, 3, 4, 10)

* label variable
	lab var		insecure_tenure ///
					"parcel acquired through potentially insecure tenure arrangement"

* apply barrier value label
	lab values	insecure_tenure barrier01

* verify construction
	tab			tenure insecure_tenure, missing
	
* keep essential variables
 	keep		holder_id household_id parcel_id mgmt1 tenure title deju1 ///
					deju2 ea_id no_title insecure_tenure

		
************************************************************************
**# 2 - end matter
************************************************************************

* save file
	qui: 			compress
	isid			holder_id parcel_id
	save 			"$export/sect2_pp_w1", replace
	
* close the log
	log	close

/* END */