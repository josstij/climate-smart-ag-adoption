* Project: lsms gender
* Created on: nov 2025
* Created by: ns
* Edited on: 12 nov 2025
* Edited by: ns
* Stata v.18.5

* does
		* cleans dataset for wave 2 pp section 3 household
		* cleans up work variables
		
* assumes
		* access to raw data 
		
* TO DO
		* done
		

************************************************************************
**# 0 - setup
************************************************************************

* define paths
	global 		root 	"$data/raw_lsms_data/nigeria/wave_2/raw"
	global 		export 	"$data/lsms_gender_data/01-refined_data/nigeria/wave_2"
	global 		logout 	"$data/lsms_gender_data/01-refined_data/nigeria/logs"
	
* open log 
	cap 		log 	close
	log 		using 	"$logout/sect3a_plantingw2", append
	

************************************************************************
**# 1 - clean data
************************************************************************

* load data
	use			"$root/sect3a_plantingw2", clear
	
* rename variables
	rename		s3aq3	respond
	rename		s3aq4	wage
	rename		s3aq5	farm
	rename		s3aq6	nfe
	
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
	save 		"$export/sect3a_plantingw2", replace
	
* close the log
	log	close

/* END */