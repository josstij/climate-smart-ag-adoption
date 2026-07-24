* Project: lsms csa
* Created on: july 2026
* Created by: jt
* Edited on: july 2026
* Edited by: jt
* Stata v.19.5

* does
	* inputs wave1 dataset for post planting crop roster csa data
	* cleans up csa variables 
	* outputs file containing improved seed indicator
	
		
* assumes
	* access to raw data 

* TO DO:
	* all
	

************************************************************************
**# 0 - setup
************************************************************************

* load project setup
	do		"C:/Users/tijer/git/UROC/climate-smart-ag-adoption/05-climate-smart/code/00_setup.do"

* define paths
	global	root 		"$raw_data/ethiopia/wave_1/raw"
	global	export 	"$clean_data/ethiopia/wave_1"
	global	logout 	"$cs_logs"
	
* create export folders
	cap		mkdir		"$clean_data/ethiopia"
	cap		mkdir		"$export"
	
* open log 
	cap		log			close
	log		using		"$logout/sect4_pp_w1", append
	

************************************************************************
**# 1 - clean data
************************************************************************

* load data
	use			"$root/sect4_pp_w1", clear

* rename variables
	rename		(pp_s4q11) ///
				(seed)
				
				
************************************************************************
**# 2 - construct CSA variables
************************************************************************

* check seed coding
	tab			seed, missing

* improved seed used on crop
	gen			seed_imp = .
	replace		seed_imp = 0 if seed == 1
	replace		seed_imp = 1 if seed == 2
	
	
	describe		holder_id parcel_id field_id seed
	
	
************************************************************************
**# 3 - aggregate to field level
************************************************************************

* number of crops reported on field
	bysort		holder_id parcel_id field_id: ///
		gen		n_crops = _N

* number of crops with nonmissing seed information
	bysort		holder_id parcel_id field_id: ///
		egen	n_seed_obs = count(seed_imp)

* identify whether any crop used improved seed
	bysort		holder_id parcel_id field_id: ///
		egen	any_seed_imp = max(seed_imp)

* construct field-level improved seed indicator
	gen			csa_seed = .
	replace		csa_seed = 1 if any_seed_imp == 1
	replace		csa_seed = 0 if any_seed_imp == 0 & ///
								n_seed_obs == n_crops
	
************************************************************************
**# 4 - label variables
************************************************************************

* define value label
	label		define		csa_yesno 0 "No" 1 "Yes"
	
* apply value labels
	label		values		seed_imp	csa_yesno
	label		values		csa_seed	csa_yesno
	
* label variables
	label		variable	seed		"Type of seed used for crop"
	label		variable	seed_imp	"Improved seed used for crop"
	label		variable	csa_seed	"Improved seed used on field"
	label		variable	n_crops		"Number of crop records on field"
	label		variable	n_seed_obs	"Number of crops with seed information"
	
	
************************************************************************
**# 5 - checks
************************************************************************

* check raw seed response and crop-level indicator
	tab			seed seed_imp, missing

* check field-level improved seed indicator
	tab			csa_seed, missing

* inspect fields with multiple crops
	tab			n_crops, missing

* check fields with incomplete seed information
	count		if n_seed_obs < n_crops

* check whether improved seed is detected despite some missing responses
	count		if csa_seed == 1 & n_seed_obs < n_crops
	
	
************************************************************************
**# 6 - prepare field-level file
************************************************************************

* identify wave
	gen			wave = 1

* keep one observation per field
	bysort		holder_id parcel_id field_id: ///
		keep	if _n == 1

* confirm field identifiers are unique
	isid		holder_id parcel_id field_id

* keep needed variables
	keep		wave holder_id parcel_id field_id ///
				csa_seed n_crops n_seed_obs

* order variables
	order		wave holder_id parcel_id field_id ///
				csa_seed n_crops n_seed_obs
				
				
************************************************************************
**# 7 - save data
************************************************************************

* save data
	save		"$export/sect4_csa_w1", replace

* close log
	log			close
	
	