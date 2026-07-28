* Project: lsms gender
* Created on: oct 2025
* Created by: jt
* Edited on: 25 oct 2025
* Edited by: jt
* Stata v.19.5

* does
	* inputs wave3 dataset for post planting parcel ownership data
	* cleans up gendered plot owner variables 
	* outputs file containing defacto owners, dejure owners, tenure
	* no beqth
		
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
	log		using	"$logout/sect2_pp_w3", append
	

************************************************************************
**# 1 - clean data
************************************************************************

* load data
		use			"$root/sect2_pp_w3", clear
		
* inspect parcel-level uniqueness
	duplicates report	holder_id parcel_id
	duplicates report	household_id parcel_id

* rename variables
	rename		(pp_saq07 pp_s2q03 pp_s2q03b pp_s2q03c_a pp_s2q03c_b ///
					pp_s2q04 pp_s2q06_a pp_s2q06_b ) ///
					(mgmt1 tenure collat defa1 defa2 title deju1 deju2)

* recode yes no for collat
	replace		collat = 0 if collat == 2
	lab			define yesno 0 "no" 1 "yes"
	lab			value collat yesno
	
* recode yes no for title
	replace 	title = 0 if title ==2
	lab			value title yesno
	
* inspect land-rights variables
	tab			tenure, missing
	tab			title, missing
	tab			collat, missing

	codebook	tenure title collat
	
* create land-certification barrier
	gen			no_title = .
	replace		no_title = 0 if title == 1
	replace		no_title = 1 if title == 0

* label variable
	lab var		no_title ///
					"household does not have parcel certificate"

* define and apply barrier value label
	lab define	barrier01 ///
					0 "no barrier" ///
					1 "barrier", replace

	lab values	no_title barrier01

* verify construction
	tab			title no_title, missing
	
* create potential tenure-security barrier
	gen			insecure_tenure = .
	replace		insecure_tenure = 0 if inlist(tenure, 1, 2, 7)
	replace		insecure_tenure = 1 if inlist(tenure, 3, 4, 5, 6)

* label variable
	lab var		insecure_tenure ///
					"parcel acquired through potentially insecure tenure arrangement"

* apply barrier value label
	lab values	insecure_tenure barrier01

* verify construction
	tab			tenure insecure_tenure, missing
	
* create parcel-transfer-rights barrier
	gen			no_transfer_right = .
	replace		no_transfer_right = 0 if collat == 1
	replace		no_transfer_right = 1 if collat == 0

* label variable
	lab var		no_transfer_right ///
					"no household right to sell parcel or use it as collateral"

* apply barrier value label
	lab values	no_transfer_right barrier01

* verify construction
	tab			collat no_transfer_right, missing
	
* keep essential variables
	keep		holder_id household_id ea_id parcel_id ///
				mgmt1 tenure collat defa1 defa2 ///
				title no_title insecure_tenure ///
				no_transfer_right deju1 deju2


************************************************************************
**# 2 - end matter
************************************************************************

* save file
	qui: 			compress
	isid			holder_id parcel_id
	save 			"$export/sect2_pp_w3", replace
	
* close the log
	log				close

/* END */