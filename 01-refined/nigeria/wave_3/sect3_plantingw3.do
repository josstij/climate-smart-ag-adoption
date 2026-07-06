* Project: lsms gender
* Created on: nov 2025
* Created by: ns
* Edited on: 12 nov 2025
* Edited by: ns
* Stata v.18.5

* does
		* cleans dataset for wave 3 pp section 3 household
		* cleans up money variables
		
* assumes
		* access to raw data 
		
* TO DO
		* find variables
		

************************************************************************
**# 0 - setup
************************************************************************

* define paths
	global 		root 	"$data/raw_lsms_data/nigeria/wave_3/raw"
	global 		export 	"$data/lsms_gender_data/01-refined_data/nigeria/wave_3"
	global 		logout 	"$data/lsms_gender_data/01-refined_data/nigeria/logs"
	
* open log 
	cap 		log 	close
	log 		using 	"$logout/sect3_plantingw3", append
	

************************************************************************
**# 1 - clean data
************************************************************************

* load data
	use			"$root/sect3_plantingw3", clear
	
* rename variables
	rename		s3q3	respond
	rename		s3q4	wage
	rename		s3q5	farm
	rename		s3q6	nfe
	
* keep
	keep 		ea hhid indiv respond wage farm nfe
	
* add variable
	gen			visit = 1

* save as temp 
	tempfile	tempdata
	save 		"`tempdata'", replace

	
************************************************************************
**# 2 - clean data - post harvest
************************************************************************

* load data
	use			"$root/sect3_harvestw3", clear

* rename variables
	rename		s3q3	respond
	rename		s3q4	wage
	rename		s3q5	farm
	rename		s3q6	nfe
	
* keep essential variables
 	keep		ea hhid indiv wage farm nfe

* generate variable
	gen 		visit = 2
	
* append post planting data
	append 		using "`tempdata'"

* tag duplicates by hhid + indiv
	duplicates 	tag hhid indiv, gen(dup)

* for duplicated persons (both visits), keep planting (visit==1)
	bys			hhid indiv (visit): keep if dup == 0 | visit == 1

* drop helper variable
	drop 		dup

************************************************************************
**# 3 - end matter
************************************************************************

* reorder
	order		ea hhid indiv respond wage farm nfe
									
* save file
	qui: 		compress
	isid		hhid indiv
	save 		"$export/sect3_plantingw3", replace
	
* close the log
	log	close

/* END */