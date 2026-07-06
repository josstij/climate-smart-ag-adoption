* Project: lsms gender
* Created on: oct 2025
* Created by: ns
* Edited on: 13 oct 2025
* Edited by: ns
* Stata v.18.5

* does
		* cleans dataset for wave 4 pp 11a
		* cleans up manager variable
		
* assumes
		* access to raw data 

* TO DO:
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
	log 		using 	"$logout/sect11a1_plantingw4", append

	
************************************************************************
**# 1 - clean data
************************************************************************

* load data
	use			"$root/sect11a1_plantingw4", clear

* rename variables
	rename		s11aq6a mgmt1
	rename		s11aq6b mgmt2
	rename		s11aq6c mgmt3
	rename		s11aq6d mgmt4
		
* keep essential variables
 	keep		zone state lga sector ea hhid plotid mgmt*
	
		
************************************************************************
**# 2 - end matter
************************************************************************

* reorder
	
	order		zone state lga sector ea hhid plotid mgmt1 mgmt2 ///
					mgmt3 mgmt4

* save file
	qui: 		compress
	isid		hhid plotid
	save 		"$export/sect11a1_plantingw4", replace
	
* close the log
	log	close

/* END */