* Project: lsms gender
* Created on: 3 nov 2025
* Created by: jt
* Edited on: 27 july 2026
* Edited by: jt
* Stata v.19.5

* does
	* inputs wave1 dataset for hh indv communication data
	* cleans up indv lvl variables 
	* outputs file containing communication
		
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
	log		using	"$logout/sect10_hh_w2", append
	

************************************************************************
**# 1 - clean data
************************************************************************

* load data
	use			"$root/sect10_hh_w2", clear

* harmonize Wave 2 identifiers
	rename		household_id household_id_w1
	rename		ea_id ea_id_w1

	rename		household_id2 household_id
	rename		ea_id2 ea_id
	
* define barrier value label
	lab define	barrier01 ///
					0 "no barrier" ///
					1 "barrier", replace
					
	isid		household_id hh_s10q00

	tab			hh_s10q00 hh_s10q01 ///
					if inlist(hh_s10q00, 7, 8, 9), missing
				
* identify ownership of communication assets
	gen			comm_asset = .
	replace		comm_asset = 0 if hh_s10q01 == 0 & ///
					inlist(hh_s10q00, 7, 8, 9)
	replace		comm_asset = 1 if hh_s10q01 > 0 & ///
					!missing(hh_s10q01) & ///
					inlist(hh_s10q00, 7, 8, 9)

* identify whether household owns any communication asset
	bysort		household_id: ///
		egen	any_communication = max(comm_asset)

* create communication-access barrier
	gen			no_communication = .
	replace		no_communication = 0 if any_communication == 1
	replace		no_communication = 1 if any_communication == 0

* label variables
	lab var		any_communication ///
					"household owns telephone, mobile phone, or radio"
	lab var		no_communication ///
					"household owns no telephone, mobile phone, or radio"

	lab values	no_communication barrier01
	
	egen		hh_tag = tag(household_id)

	tab			any_communication if hh_tag, missing
	tab			no_communication if hh_tag, missing

* retain one household-level record
	keep		if inlist(hh_s10q00, 7, 8, 9)

	bysort		household_id: ///
		keep	if _n == 1

* keep essential variables
	keep		household_id ea_id ///
				any_communication no_communication

* confirm household-level uniqueness
	isid		household_id
	
* verify communication-access barrier
	egen		hh_tag = tag(household_id)

	tab			any_communication if hh_tag, missing
	tab			no_communication if hh_tag, missing
	
	
************************************************************************
**# 2 - end matter
************************************************************************

* save file
	qui: 			compress
	isid			household_id
	save 			"$export/sect10_hh_w2", replace
	
* close the log
	log	close

/* END */