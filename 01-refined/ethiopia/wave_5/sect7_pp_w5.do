* Project: lsms gender
* Created on: july 2026
* Created by: jt
* Edited on: 27 july 2026
* Edited by: jt
* Stata v.19.5

* does
	* inputs wave4 dataset for post planting parcel ownership data
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
	global	root 	"$data/raw_lsms_data/ethiopia/wave_5/raw"
	global	export 	"$data/lsms_gender_data/01-refined_data/ethiopia/wave_5"
	global	logout 	"$data/lsms_gender_data/01-refined_data/ethiopia/logs"
	
* open log 
	cap		log		close
	log		using	"$logout/sect7_pp_w5", append
	

************************************************************************
**# 1 - inspect data
************************************************************************

	use			"$root/sect7_pp_w5", clear
	
* inspect wave 5 identifiers
	describe	holder_id household_id* ea_id*

* locate relevant wave 5 questions
	lookfor		extension
	lookfor		credit
	lookfor		advisory
	
* confirm observation level
	isid		holder_id

* inspect response coding
	codebook	s7q04 s7q06 s7q09

	tab			s7q04, missing
	tab			s7q06, missing
	tab			s7q09, missing

* define barrier value label
	lab define	barrier01 ///
					0 "no barrier" ///
					1 "barrier", replace

* create extension-program barrier
	gen			no_extension = .
	replace		no_extension = 0 if s7q04 == 1
	replace		no_extension = 1 if s7q04 == 2

	lab var		no_extension ///
					"does not participate in extension program"

* create credit-access barrier
	gen			no_credit = .
	replace		no_credit = 0 if s7q06 == 1
	replace		no_credit = 1 if s7q06 == 2

	lab var		no_credit ///
					"does not receive credit services"

* create advisory-services barrier
	gen			no_advisory = .
	replace		no_advisory = 1 if s7q09 == 1
	replace		no_advisory = 0 if s7q09 == 2

	lab var		no_advisory ///
					"does not receive advisory services"

* apply barrier labels
	lab values	no_extension no_credit no_advisory barrier01

* verify constructions
	tab			s7q04 no_extension, missing
	tab			s7q06 no_credit, missing
	tab			s7q09 no_advisory, missing

* keep essential variables
	keep			holder_id household_id ea_id ///
					no_credit no_extension no_advisory


************************************************************************
**# 2 - end matter
************************************************************************

* save file
	qui:			compress
	isid			holder_id
	save			"$export/sect7_pp_w5", replace

* close the log
	log			close

/* END */