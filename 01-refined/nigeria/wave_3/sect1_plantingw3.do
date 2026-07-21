* Project: lsms gender
* Created on: oct 2025
* Created by: ns
* Edited on: 20 oct 2025
* Edited by: ns
* Stata v.18.5

* does
		* cleans dataset for wave 3 pp household
		* cleans up gender variables
		
* assumes
		* access to raw data 
		
* TO DO
		* done
		

************************************************************************
**# 0 - setup
************************************************************************

* define paths
	global 		root 	"$data/raw_lsms_data/nigeria/wave_3/raw"
	global 		export 	"$data/lsms_gender_data/01-refined_data/nigeria/wave_3"
	global 		logout 	"$data/lsms_gender_data/01-refined_data/nigeria/logs"
	
* open log 
	cap 		log 	close
	log 		using 	"$logout/sect1_plantingw3", append
	
	
************************************************************************
**# 1 - clean data - post planting
************************************************************************

* load data
	use			"$root/sect1_plantingw3", clear

* rename variables 
	rename		s1q2	sex 
	rename		s1q3	relate
	rename		s1q4	away	
	rename		s1q6	age
	rename		s1q8	mrry
	
* keep essential variables
 	keep		zone lga sector ea hhid indiv away relate sex age mrry 
	
							
************************************************************************
**# 2 - end matter
************************************************************************

* reorder
	order		zone lga sector ea hhid indiv away sex relate age mrry		
							
* save file
	qui: 		compress
	isid		hhid indiv
	save 		"$export/sect1_plantingw3", replace
	
* close the log
	log	close

/* END */