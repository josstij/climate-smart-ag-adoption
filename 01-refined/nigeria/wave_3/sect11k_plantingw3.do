* Project: lsms gender
* Created on: oct 2025
* Created by: ns
* Edited on: 22 oct 2025
* Edited by: ns
* Stata v.18.5

* does
		* cleans dataset for wave 3 pp 11h
		* cleans up money manager variable
		
* assumes
		* access to raw data 

* TO DO:
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
	log 		using 	"$logout/sect11k_plantingw3", append

	
************************************************************************
**# 1 - clean data
************************************************************************

* load data
	use			"$root/sect11k_plantingw3", clear

* rename variables
	rename		s11kq7a		monman1
	rename		s11kq7b		monman2
		
* keep essential variables
 	keep		zone state lga sector ea hhid prod_cd monman1 monman2
	
		
************************************************************************
**# 2 - end matter
************************************************************************

* reorder
	order		zone state lga sector ea hhid prod_cd monman1 monman2

* save file
	qui: 		compress
	isid		hhid prod_cd
	save 		"$export/sect11k_plantingw3", replace
	
* close the log
	log	close

/* END */