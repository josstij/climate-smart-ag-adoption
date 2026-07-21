* Project: lsms gender
* Created on: oct 2025
* Created by: ns
* Edited on: 22 oct 2025
* Edited by: ns
* Stata v.18.5

* does
		* cleans dataset for wave 1 pp 11h
		* cleans up money manager variable
		
* assumes
		* access to raw data 

* TO DO:
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
	log 		using 	"$logout/sect11h_plantingw1", append

	
************************************************************************
**# 1 - clean data
************************************************************************

* load data
	use			"$root/sect11h_plantingw1", clear

* rename variables
	rename		s11hq7a		monman1
	rename		s11hq7b		monman2
	rename		s11hq14a	monman3
	rename		s11hq14b	monman4
		
* keep essential variables
 	keep		zone state lga sector ea hhid plotid cropid cropcode monman1 ///
				monman2 monman3 monman4
	
		
************************************************************************
**# 2 - end matter
************************************************************************

* reorder
	order		zone state lga sector ea hhid plotid cropid cropcode monman1 /// 
				monman2 monman3 monman4

* save file
	qui: 		compress
	isid		hhid plotid cropid
	save 		"$export/sect11h_plantingw1", replace
	
* close the log
	log	close

/* END */