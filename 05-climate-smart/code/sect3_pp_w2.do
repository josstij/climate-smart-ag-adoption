* Project: lsms csa
* Created on: july 2026
* Created by: jt
* Edited on: july 2026
* Edited by: jt
* Stata v.19.5

* does
	* inputs wave2 dataset for post planting parcel csa data
	* cleans up csa variables 
	* outputs file containing irrigation, manure or compost, land conservation
	
		
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
	global	root 		"$raw_data/ethiopia/wave_2/raw"
	global	export 	"$clean_data/ethiopia/wave_2"
	global	logout 	"$cs_logs"
	
* create export folders
	cap		mkdir		"$clean_data"
	cap		mkdir		"$clean_data/ethiopia/wave_2"
	cap		mkdir		"$export"
	
* open log 
	cap		log			close
	log		using		"$logout/sect3_pp_w2", append
	

************************************************************************
**# 1 - clean data
************************************************************************

* load raw Section 3 data
	use			"$root/sect3_pp_w2", clear

* inspect expected variables
	describe	holder_id parcel_id field_id ///
				pp_s3q12 pp_s3q21 pp_s3q23 ///
				pp_s3q32 pp_s3q33

	tab			pp_s3q12, missing
	tab			pp_s3q21, missing
	tab			pp_s3q23, missing
	tab			pp_s3q32, missing
	tab			pp_s3q33, missing
				
************************************************************************
**# 2 - construct CSA indicators
************************************************************************

* rename raw variables
	rename		pp_s3q12	irr
	rename		pp_s3q21	man
	rename		pp_s3q23	comp
	rename		pp_s3q32	ero
	rename		pp_s3q33	prevero

* irrigation
	gen			csa_irr = .
	replace		csa_irr = 1 if irr == 1
	replace		csa_irr = 0 if irr == 2
	
* manure
	gen			csa_man = .
	replace		csa_man = 1 if man == 1
	replace		csa_man = 0 if man == 2
	
* compost
	gen			csa_comp = .
	replace		csa_comp = 1 if comp == 1
	replace		csa_comp = 0 if comp == 2
	
* manure or compost
	gen			csa_soil = .
	replace		csa_soil = 1 if csa_man == 1 | ///
				csa_comp == 1
	replace		csa_soil = 0 if csa_man == 0 & ///
				csa_comp == 0
	
* erosion prevention
	gen			csa_cons = .
	replace		csa_cons = 1 if ero == 1
	replace		csa_cons = 0 if ero == 2
	
	
************************************************************************
**# 3 - label and check variables
************************************************************************

* define value label
	label		define		csa_yesno 0 "No" 1 "Yes", replace
	
* apply value labels
	label		values		csa_irr	csa_yesno
	label		values		csa_man	csa_yesno
	label		values		csa_comp	csa_yesno
	label		values		csa_soil	csa_yesno
	label		values		csa_cons	csa_yesno
	
* label variables
	label		variable	csa_irr		"Field irrigated"
	label		variable	csa_man		"Manure used on field"
	label		variable	csa_comp	"Compost used on field"
	label		variable	csa_soil	"Manure or compost used on field"
	label		variable	csa_cons	"Field protected from erosion"
	
* confirm identifiers are unique
	isid		holder_id parcel_id field_id
	
* check indicators
	tab			csa_irr, missing
	tab			csa_man, missing
	tab			csa_comp, missing
	tab			csa_soil, missing
	tab			csa_cons, missing
	
	
************************************************************************
**# 4 - save data
************************************************************************

* identify wave
	gen			wave = 2
	
* retain required variables
	keep		wave holder_id parcel_id field_id ///
				csa_irr csa_man csa_comp ///
				csa_soil csa_cons
	
* order variables
	order		wave holder_id parcel_id field_id ///
				csa_irr csa_man csa_comp ///
				csa_soil csa_cons
	
* save cleaned Section 3 file
	save		"$export/sect3_csa_w2", replace
	
* close log
	log			close