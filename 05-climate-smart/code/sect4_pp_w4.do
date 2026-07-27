* Project: lsms csa
* Created on: july 2026
* Created by: jt
* Edited on: july 2026
* Edited by: jt
* Stata v.19.5

* does
	* inputs wave4 dataset for post planting crop roster csa data
	* cleans up csa variables 
	* outputs file containing improved seed indicator
	
		
* assumes
	* access to raw data 

* TO DO:
	* DONE !!
	

************************************************************************
**# 0 - setup
************************************************************************

* load project setup
	do		"C:/Users/tijer/git/UROC/climate-smart-ag-adoption/05-climate-smart/code/00_setup.do"

* define paths
	global	root		"$raw_data/ethiopia/wave_4/raw"
	global	export		"$clean_data/ethiopia/wave_4"
	global	logout		"$cs_logs"
	
* open log
	cap		log			close
	log		using		"$logout/sect4_pp_w4", append
	

************************************************************************
**# 1 - inspect raw data
************************************************************************

* load raw Section 4 data
	use			"$root/sect4_pp_w4", clear

* inspect identifiers and seed question
	describe	holder_id parcel_id field_id s4q11

* inspect labeled and numeric response categories
	tab			s4q11, missing
	tab			s4q11, missing nolabel

* check whether fields contain multiple crop records
	duplicates	report holder_id parcel_id field_id
	
	
************************************************************************
**# 2 - construct improved seed indicator
************************************************************************

* rename raw seed variable
	rename		s4q11		seed

* identify improved seed at the crop level
	gen			seed_imp = .
	replace		seed_imp = 0 if seed == 1
	replace		seed_imp = 1 if inlist(seed, 2, 3, 4)

* count crop records on each field
	bysort		holder_id parcel_id field_id: ///
				gen n_crops = _N

* count crop records with usable seed information
	bysort		holder_id parcel_id field_id: ///
				egen n_seed_obs = count(seed_imp)

* identify whether any crop used improved seed
	bysort		holder_id parcel_id field_id: ///
				egen any_seed_imp = max(seed_imp)

* construct field-level improved seed indicator
	gen			csa_seed = .
	replace		csa_seed = 1 if any_seed_imp == 1
	replace		csa_seed = 0 if any_seed_imp == 0 & ///
				n_seed_obs == n_crops
				
				
************************************************************************
**# 3 - label and check variables
************************************************************************

* define value label
	label		define		csa_yesno 0 "No" 1 "Yes", replace

* apply value label
	label		values		csa_seed csa_yesno

* label variable
	label		variable	csa_seed ///
				"Improved seed used on field"

* retain one observation per field
	bysort		holder_id parcel_id field_id: ///
				keep if _n == 1

* confirm field identifiers are unique
	isid		holder_id parcel_id field_id

* check field-level seed indicator
	tab			csa_seed, missing
	tab			n_seed_obs n_crops, missing
	
	
************************************************************************
**# 4 - save data
************************************************************************

* identify wave
	gen			wave = 4

* retain required variables
	keep		wave holder_id parcel_id field_id ///
				csa_seed n_crops n_seed_obs

* order variables
	order		wave holder_id parcel_id field_id ///
				csa_seed n_crops n_seed_obs

* save cleaned Section 4 file
	save		"$export/sect4_csa_w4", replace

* close log
	log			close
	
	