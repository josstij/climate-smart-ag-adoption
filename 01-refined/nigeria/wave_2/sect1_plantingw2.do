* Project: lsms gender
* Created on: oct 2025
* Created by: ns
* Edited on: 20 oct 2025
* Edited by: ns
* Stata v.18.5

* does
		* cleans dataset for wave 2 pp household
		* cleans up gender variables
		
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
	log 		using 	"$logout/sect1_plantingw2", append
	
************************************************************************
**# 1 - clean data
************************************************************************

* load data
	use			"$root/sect1_plantingw2", clear
	
	
* rename variables 
	rename		s1q2	sex 
	rename		s1q3	relate
	rename		s1q4	away
	rename		s1q6	age
	rename		s1q8	mrry
	
* keep essential variables
 	keep		zone state lga sector ea hhid indiv relate sex age mrry away


************************************************************************
**# 2 - end matter
************************************************************************

* reorder
	order		zone state lga sector ea hhid indiv relate sex age mrry away
				
							
* save file
	qui: 		compress
	isid		hhid indiv
	save 		"$export/sect1_plantingw2", replace
	
* close the log
	log	close

/* END */