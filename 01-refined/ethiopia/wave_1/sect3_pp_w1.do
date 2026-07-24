* Project: lsms csa
* Created on: july 2026
* Created by: jt
* Edited on: july 2026
* Edited by: jt
* Stata v.19.5

* does
	* inputs wave1 dataset for post planting parcel csa data
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
	global	root 		"$raw_data/ethiopia/wave_1/raw"
	global	export 	"$clean_data/ethiopia/wave_1"
	global	logout 	"$cs_logs"
	
* create export folders
	cap		mkdir		"$clean_data/ethiopia"
	cap		mkdir		"$export"
	
* open log 
	cap		log			close
	log		using		"$logout/sect3_pp_w1", append
	

************************************************************************
**# 1 - clean data
************************************************************************

* load data
	use			"$root/sect3_pp_w1", clear

* rename variables
	rename		(pp_s3q12 pp_s3q21 pp_s3q23 pp_s3q32 pp_s3q33) ///
				(irr      man      comp     ero      prevero)
				
				
************************************************************************
**# 2 - construct CSA variables
************************************************************************

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
	
* improved soil fertility
	gen			csa_soil = .
	replace		csa_soil = 1 if csa_man == 1 | csa_comp == 1
	replace		csa_soil = 0 if csa_man == 0 & csa_comp == 0
	
* land conservation
	gen			csa_cons = .
	replace		csa_cons = 1 if ero == 1
	replace		csa_cons = 0 if ero == 2
	
	
************************************************************************
**# 3 - label variables
************************************************************************

* define value label
	label		define		csa_yesno 0 "No" 1 "Yes"
	
* apply value labels
	label		values		csa_irr 	csa_yesno
	label		values		csa_man 	csa_yesno
	label		values		csa_comp 	csa_yesno
	label		values		csa_soil 	csa_yesno
	label		values		csa_cons 	csa_yesno
	
* label variables
	label		variable	csa_irr		"Field irrigated"
	label		variable	csa_man		"Manure used on field"
	label		variable	csa_comp	"Compost used on field"
	label		variable	csa_soil	"Manure or compost used on field"
	label		variable	csa_cons	"Field protected from erosion"
	label		variable	prevero		"Method used to prevent erosion"
	
	
************************************************************************
**# 4 - checks
************************************************************************

* check original and constructed variables
	tab			irr csa_irr, missing
	tab			man csa_man, missing
	tab			comp csa_comp, missing
	tab			ero csa_cons, missing
	
* check soil fertility construction
	tab			csa_man csa_comp, missing
	tab			csa_soil, missing
	
* check erosion prevention and method
	tab			ero prevero, missing
	
* check inconsistent erosion responses
	count		if ero == 1 & missing(prevero)
	count		if ero == 2 & !missing(prevero)
	
	
************************************************************************
**# 5 - save data
************************************************************************

* create export folders
	cap		mkdir		"$clean_data"
	cap		mkdir		"$clean_data/ethiopia"
	cap		mkdir		"$clean_data/ethiopia/wave_1"

* identify wave
	gen			wave = 1
	
* order variables
	order		wave irr csa_irr man csa_man comp csa_comp ///
				csa_soil ero csa_cons prevero
	
* save data
	save		"$export/sect3_csa_w1.dta", replace
	
* close log
	log			close