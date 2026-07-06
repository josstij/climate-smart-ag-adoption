* Project: lsms gender
* Created on: oct 2025
* Created by: ns
* Edited on: 11 nov 2025
* Edited by: ns
* Stata v.18.5

* does
		* cleans dataset for wave 1 pp household
		* cleans up education variables
		
* assumes
		* access to raw data 
		
* TO DO
		* done
		

************************************************************************
**# 0 - setup
************************************************************************

* define paths
	global 		root 	"$data/raw_lsms_data/nigeria/wave_1/raw"
	global 		export 	"$data/lsms_gender_data/01-refined_data/nigeria/wave_1"
	global 		logout 	"$data/lsms_gender_data/01-refined_data/nigeria/logs"
	
* open log 
	cap 		log 	close
	log 		using 	"$logout/sect2_plantingw1", append
	
	
************************************************************************
**# 1 - clean data
************************************************************************

* load data
	use			"$root/sect2_plantingw1", clear

* rename variables
	rename		s2q2	respond
	rename		s2q7	edu
	
* replace edu
	replace		edu = 0 if edu == . & (s2q3 == 2 | s2q4 == 2)
	
* keep essential variables
 	keep		ea hhid indiv respond edu

	
************************************************************************
**# 2 - end matter
************************************************************************

* reorder
	order		ea hhid indiv respond edu
					
* save file
	qui: 		compress
	isid		hhid indiv
	save 		"$export/sect2_plantingw1", replace
	
* close the log
	log	close

/* END */