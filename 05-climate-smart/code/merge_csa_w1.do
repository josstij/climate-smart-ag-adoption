* Project: lsms csa
* Created on: july 2026
* Created by: jt
* Edited on: july 2026
* Edited by: jt
* Stata v.19.5

* does
	* inputs cleaned Wave 1 Section 3 and Section 4 CSA files
	* merges field-level CSA indicators
	* constructs Wave 1 CSA adoption outcomes
	* outputs Wave 1 CSA dataset
	
* assumes
	* Section 3 and Section 4 CSA files have been cleaned
	* field identifiers are unique in both files

* TO DO:
	* inspect unmatched observations
	* confirm treatment of missing CSA indicators
	

************************************************************************
**# 0 - setup
************************************************************************

* load project setup
	do		"C:/Users/tijer/git/UROC/climate-smart-ag-adoption/05-climate-smart/code/00_setup.do"

* define paths
	global	root 		"$clean_data/ethiopia/wave_1"
	global	export 	"$clean_data/ethiopia/wave_1"
	global	logout 	"$cs_logs"
	
* open log 
	cap		log			close
	log		using		"$logout/merge_csa_w1", append
	

************************************************************************
**# 1 - merge CSA files
************************************************************************

* load Section 3 CSA file
	use			"$root/sect3_csa_w1", clear
	
* confirm field identifiers are unique
	isid		holder_id parcel_id field_id
	
* merge improved seed indicator
	merge		1:1 holder_id parcel_id field_id ///
				using "$root/sect4_csa_w1"
				
* check merge results
	tab			_merge
	
	
************************************************************************
**# 2 - inspect unmatched observations
************************************************************************

* inspect Section 4-only observations
	list		holder_id parcel_id field_id ///
				csa_seed n_crops n_seed_obs ///
				if _merge == 2, clean noobs
	
* summarize CSA indicators for Section 3-only observations
	tab			csa_irr	if _merge == 1, missing
	tab			csa_soil	if _merge == 1, missing
	tab			csa_cons	if _merge == 1, missing
	
* count Section 3-only observations with available CSA information
	count		if _merge == 1 & ///
				(!missing(csa_irr) | ///
				 !missing(csa_soil) | ///
				 !missing(csa_cons))
	
* search for variables identifying cultivation or planted fields
	lookfor		cultivated
	lookfor		planted
	lookfor		crop
	lookfor		fallow
	

************************************************************************
**# 3 - define cultivated field sample
************************************************************************

* remove fields without a crop roster observation
	drop		if _merge == 1
	
* check cultivated field sample
	tab			_merge
	
* remove merge variable
	drop		_merge
	
* confirm field identifiers remain unique
	isid		holder_id parcel_id field_id
	
* check availability of CSA indicators
	tab			csa_irr, missing
	tab			csa_seed, missing
	tab			csa_soil, missing
	tab			csa_cons, missing
	
	
************************************************************************
**# 4 - construct CSA outcomes
************************************************************************

* count number of observed CSA indicators
	egen		csa_n_obs = rownonmiss(csa_irr csa_seed ///
				csa_soil csa_cons)

* count adopted practices among observed indicators
	egen		csa_count_obs = rowtotal(csa_irr csa_seed ///
				csa_soil csa_cons)

* set count to missing when all four indicators are missing
	replace		csa_count_obs = . if csa_n_obs == 0

* adoption of any observed CSA practice
	gen			any_csa = .
	replace		any_csa = 1 if csa_count_obs > 0 & ///
				!missing(csa_count_obs)
	replace		any_csa = 0 if csa_count_obs == 0 & ///
				csa_n_obs > 0

* identify complete CSA observations
	gen			csa_complete = csa_n_obs == 4

* construct complete-case adoption count
	gen			csa_count = csa_count_obs if csa_complete == 1

* construct complete-case any-adoption indicator
	gen			any_csa_complete = any_csa if csa_complete == 1
	
	
************************************************************************
**# 5 - label variables
************************************************************************

* apply value labels
	label		values		any_csa		csa_yesno
	label		values		csa_complete	csa_yesno
	label		values		any_csa_complete csa_yesno

* label variables
	label		variable	csa_n_obs ///
				"Number of nonmissing CSA indicators"

	label		variable	csa_count_obs ///
				"Number of adopted practices among observed indicators"

	label		variable	any_csa ///
				"Adopted any observed CSA practice"

	label		variable	csa_complete ///
				"All four CSA indicators observed"

	label		variable	csa_count ///
				"Number of adopted CSA practices, complete cases"

	label		variable	any_csa_complete ///
				"Adopted any CSA practice, complete cases"
	
	
************************************************************************
**# 6 - checks
************************************************************************

* check number of observed indicators
	tab			csa_n_obs, missing

* check preliminary adoption outcomes
	tab			any_csa, missing
	tab			csa_count_obs, missing

* check complete-case sample
	tab			csa_complete, missing
	tab			any_csa_complete, missing
	tab			csa_count, missing

* summarize individual practices
	summarize	csa_irr csa_seed csa_soil csa_cons ///
				any_csa csa_count_obs
	
	
************************************************************************
**# 7 - save data
************************************************************************

* confirm wave
	cap		drop		wave
	gen			wave = 1

* order variables
	order		wave holder_id parcel_id field_id ///
				csa_irr csa_seed csa_soil csa_cons ///
				csa_n_obs csa_count_obs any_csa ///
				csa_complete csa_count any_csa_complete

* save data
	save		"$export/csa_w1", replace

* close log
	log			close
	