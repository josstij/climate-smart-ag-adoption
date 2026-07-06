* Project: lsms gender dynamics
* Created on: June 2025
* Created by: george hyland
* Edited on: 22 july 2025
* Edited by: alj
* Stata v.19.5

* does
		* cleans dataset for agricultural panel
		* cleans up gendered plot variables 
		
* assumes
	* access to raw data 

* TO DO:
	* done!
		
************************************************************************
**# 0 - setup
************************************************************************

* define paths
	global root 	"$data/raw_lsms_data/malawi/harmonized/wave_3"
	global export 	"$data/lsms_gender_data/01-refined_data/malawi/wave_3"
	global logout 	"$data/lsms_gender_data/01-refined_data/malawi/logs"
	
* open log 
	log using "$logout/ag_mod_b2_16", append


************************************************************************
**# 1 - clean data
************************************************************************

* load data
		use			"$root/ag_mod_b2_16", clear

* merge data
		merge		1:m y3_hhid gardenid using "$root/ag_mod_d_16"

		drop		_merge
		
/*  	Result                      Number of obs
    -----------------------------------------
    Not matched                             0
    Matched                             4,042  (_merge==3)
    -----------------------------------------
	
*/

* rename variables
		rename 		(ag_b203_1a ag_b203_1b ag_b213_1__0 ag_b213_1__1 ag_b213__1 ag_b213__0 ///
						ag_d01 ag_d01_2a ag_d01_2b ag_d02) ///
					(acquire1 acquire2 useright1 useright2 owner1 owner2 ///
						decmake1 decmake2 decmake3 id_resp)
		
* convert unit codes to strings
		label 		define acquire1 1 "Head" 2 "Spouse" 3 "Child" 4 "Grandchild" ///
						5 "Niece/Nephew" 6 "Parent" 7 "Sibling" 8 "S/D In-Law" ///
						9 "B/S In-Law" 10 "Grandparent" 11 "F/M In-Law" 12 "OtherRel" ///
						13 "Serv_Rel" 14 "Lod_Rel" 15 "OtherNR" 16 "Other"
		label 		values (acquire1 acquire2 useright1 useright2 owner1 owner2 ///
						decmake1 decmake2 decmake3 id_resp) acquire1

* keeps essential variables
		keep		y3_hhid gardenid plotid acquire1 acquire2 useright1 useright2 ///
						owner1 owner2 decmake1 decmake2 decmake3 id_resp
		
************************************************************************
**# 2 - end matter
************************************************************************

* save file
	qui: 			compress
	save 			"$export/ag_b2_16", replace
	
* close the log
	log	close

/* END */