/* BEGIN */

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
		/*
************************************************************************
**# 0 - setup
************************************************************************

* define paths
	global root 	"$data/MWI_2010-2019_IHPS_v06_M_Stata"
	global export 	"$data/refined/wave_4"
	global logout 	"$data/log"
	
* open log 
	cap log close 
	log using "$logout/mwi_wth_p", append


************************************************************************
**# 1 - clean data
************************************************************************

* load data
		use			"$root/ag_mod_b2_19", clear
	
* check for unique var
		*isid		y4_hhid
		*no unique id found

* merge data
		merge		1:m y4_hhid gardenid using "$root/ag_mod_d_19"

		drop		_merge
		
/*  	Result                      Number of obs
    -----------------------------------------
    Not matched                             3
        from master                         3  (_merge==1)
        from using                          0  (_merge==2)

    Matched                             5,570  (_merge==3)
	-----------------------------------------
	
*/

* rename variables
		rename		(ag_b203_1a ag_b203_1b ag_b213_1__0 ag_b213_1__1 ///
						ag_b213__0 ag_b213__1 ag_d01 ag_d01_2a ag_d01_2b ag_d02) ///
						(acquire1 acquire2 useright1 useright2 owner1 owner2 ///
						decmake1 decmake2 decmake3 id_resp)
		
* convert unit codes to strings
		label 		define acquire1 1 "Head" 2 "Spouse" 3 "Child" 4 "Grandchild" ///
						5 "Niece/Nephew" 6 "Parent" 7 "Sibling" 8 "S/D In-Law" ///
						9 "B/S In-Law" 10 "Grandparent" 11 "F/M In-Law" 12 "OtherRel" ///
						13 "Serv_Rel" 14 "Lod_Rel" 15 "OtherNR" 16 "Other"
		label 		values (acquire1 acquire2 useright1 useright2 owner1 owner2 ///
						decmake1 decmake2 decmake3 id_resp) acquire1
		
* keep essential variables
 		keep		y4_hhid gardenid plotid acquire1 acquire2 useright1 useright2 ///
						owner1 owner2 decmake1 decmake2 decmake3 id_resp

************************************************************************
**# 2 - end matter
************************************************************************

* save file
*	isid			y4_hhid gardenid
	*** a problem maybe to deal with later but there are missing values here
	qui: 			compress
	save 			"$export/ag_sec_19", replace
	
* close the log
	log	close

/* END */