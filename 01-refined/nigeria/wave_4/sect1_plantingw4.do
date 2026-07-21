* Project: lsms gender
* Created on: oct 2025
* Created by: ns
* Edited on: 5 nov 2025
* Edited by: ns
* Stata v.18.5

* does
		* cleans dataset for wave 4 pp household
		* cleans up gender variables
		
* assumes
		* access to raw data 
		
* TO DO
		* done
		

************************************************************************
**# 0 - setup
************************************************************************

* define paths
	global 		root 	"$data/raw_lsms_data/nigeria/wave_4/raw"
	global 		export 	"$data/lsms_gender_data/01-refined_data/nigeria/wave_4"
	global 		logout 	"$data/lsms_gender_data/01-refined_data/nigeria/logs"
	
* open log 
	cap 		log 	close
	log 		using 	"$logout/sect1_plantingw4", append
	
************************************************************************
**# 1 - clean data
************************************************************************

* load data
	use			"$root/sect1_plantingw4", clear
	
* rename variables 
	rename		s1q2	sex 
	rename		s1q3	relate
	rename		s1q4	away
	rename		s1q6	age
	rename		s1q8	mrry
	
* keep essential variables, state variable removed in w3
 	keep		zone state lga sector ea hhid indiv relate away sex age mrry 

							
************************************************************************
**# 2 - end matter
************************************************************************

* reorder
	order		zone lga sector ea hhid indiv sex relate away age mrry
				
* save file
	qui: 		compress
	isid		hhid indiv
	save 		"$export/sect1_plantingw4", replace
	
* close the log
	log	close

/* END */