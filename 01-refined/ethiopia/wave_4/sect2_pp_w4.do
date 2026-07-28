* Project: lsms gender
* Created on: oct 2025
* Created by: jt
* Edited on: 7 april 2026
* Edited by: jt
* Stata v.19.5

* does
	* inputs wave4 dataset for post planting parcel ownership data
	* cleans up gendered plot owner variables 
	* outputs file containing defacto owners, dejure owners, tenure, beqth
		
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
	log		using	"$logout/sect2_pp_w4", append
	

************************************************************************
**# 1 - clean data
************************************************************************

* load data
		use			"$root/sect2_pp_w4", clear
		
* confirm parcel observation level
	isid		holder_id parcel_id

* inspect land-rights questions
	codebook	s2q05 s2q06 s2q03

* inspect response distributions
	tab			s2q05, missing
	tab			s2q06, missing
	tab			s2q03, missing

* rename variables
	rename		(s2q01a s2q05 s2q06 s2q07_1 s2q07_2 s2q03 s2q04b_1 s2q04b_2 s2q04b_3 ///
					s2q04b_4) ///
					(mgmt1 tenure collat defa1 defa2 title deju1 deju2 deju3 deju4)
					
* define barrier value label
	lab define	barrier01 ///
					0 "no barrier" ///
					1 "barrier", replace

* recode yes/no variables
	lab define	yesno ///
					0 "no" ///
					1 "yes", replace

	local		ctb collat title

	foreach	v of varlist `ctb' {
		replace		`v' = 0 if `v' == 2
		lab values	`v' yesno
	}

* define barrier value label
	lab define	barrier01 ///
					0 "no barrier" ///
					1 "barrier", replace

* create parcel-document barrier
	gen			no_title = .
	replace		no_title = 0 if title == 1
	replace		no_title = 1 if title == 0

	lab var		no_title ///
					"household does not have parcel document"

	lab values	no_title barrier01

* verify construction
	tab			title no_title, missing
	
* create potential tenure-security barrier
	gen			insecure_tenure = .
	replace		insecure_tenure = 0 if inlist(tenure, 1, 2, 7)
	replace		insecure_tenure = 1 if inlist(tenure, 3, 4, 5, 6)

	lab var		insecure_tenure ///
					"parcel acquired through potentially insecure tenure arrangement"

	lab values	insecure_tenure barrier01

* verify construction
	tab			tenure insecure_tenure, missing
	
* create parcel-transfer-rights barrier
	gen			no_transfer_right = .
	replace		no_transfer_right = 0 if collat == 1
	replace		no_transfer_right = 1 if collat == 0

	lab var		no_transfer_right ///
					"no household right to sell parcel or use it as collateral"

	lab values	no_transfer_right barrier01

* verify construction
	tab			collat no_transfer_right, missing
	
* keep essential variables
	keep		holder_id household_id parcel_id mgmt1 tenure ///
				collat title defa1 defa2 deju1 deju2 deju3 deju4 ///
				no_title insecure_tenure no_transfer_right ea_id

		
************************************************************************
**# 2 - end matter
************************************************************************

* save file
	qui: 			compress
	isid			holder_id parcel_id
	save 			"$export/sect2_pp_w4", replace
	
* close the log
	log	close

/* END */