* Project: lsms gender
* Created on: nov 2025
* Created by: ns
* Edited on: 10 nov 2025
* Edited by: ns
* Stata v.18.5

* does
		* cleans dataset for wave 4 pp section 3 household
		* cleans up money variables
		
* assumes
		* access to raw data 
		
* TO DO
		* find variables
		

************************************************************************
**# 0 - setup
************************************************************************

* define paths
	global 		root 	"$data/raw_lsms_data/nigeria/wave_4/raw"
	global 		export 	"$data/lsms_gender_data/01-refined_data/nigeria/wave_4"
	global 		logout 	"$data/lsms_gender_data/01-refined_data/nigeria/logs"
	
* open log 
	cap 		log 	close
	log 		using 	"$logout/sect3_plantingw4", append
	

************************************************************************
**# 1 - clean data
************************************************************************

* load data
	use			"$root/sect3_plantingw4", clear
	
* rename variables
	rename		s3q3	respond
	rename		s3q4	wage
	rename		s3q5	farm
	rename		s3q6	nfe
	
* keep
	keep 		ea hhid indiv respond wage farm nfe
	

************************************************************************
**# 2 - end matter
************************************************************************

* reorder
	order		ea hhid indiv respond wage farm nfe
									
* save file
	qui: 		compress
	isid		hhid indiv
	save 		"$export/sect3_plantingw4", replace
	
* close the log
	log	close

/* END */