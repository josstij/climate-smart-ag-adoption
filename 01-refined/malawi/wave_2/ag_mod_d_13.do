* Project: lsms gender dynamics
* Created on: July 2025
* Created by: george hyland
* Edited on: 22 July 2025
* Edited by: alj
* Stata v.19.5

* does
		* cleans dataset for 2013 ag panel
		* cleans up gendered plot variables 
		
* assumes
	* access to raw data 

* TO DO:
	* done!

************************************************************************
**# 0 - setup
************************************************************************

* define paths
	global root 	"$data/raw_lsms_data/malawi/harmonized/wave_2"
	global export 	"$data/lsms_gender_data/01-refined_data/malawi/wave_2"
	global logout 	"$data/lsms_gender_data/01-refined_data/malawi/logs"
	
* open log 
	cap log close
	log using "$logout/ag_mod_d_13", append

************************************************************************
**# 1 - clean data
************************************************************************

* load data
		use			"$root/ag_mod_d_13", clear

* rename variables
		rename		(ag_d00 ag_d01 ag_d01_2a ag_d01_2b ag_d02 ag_d04a ag_d04b ) ///
						(plotid decmake1 decmake2 decmake3 id_resp owner1 owner2)
		
* convert unit codes to strings
		label 		define change 1 "Head" 2 "Spouse" 3 "Child" 4 "Grandchild" ///
						5 "Niece/Nephew" 6 "Parent" 7 "Sibling" 8 "S/D In-Law" ///
						9 "B/S In-Law" 10 "Grandparent" 11 "F/M In-Law" 12 "OtherRel" ///
						13 "Serv_Rel" 14 "Lod_Rel" 15 "OtherNR" 16 "Other"
		label		values (owner1 owner2 decmake1 decmake2 decmake3 id_resp) change
		
* keep essential variables
 		keep		y2_hhid plotid plotid decmake1 decmake2 decmake3 id_resp owner1 owner2

************************************************************************
**# 2 - end matter
************************************************************************

* save file
	qui: 			compress
	save 			"$export/ag_d_13", replace
	
* close the log
	log	close

/* END */