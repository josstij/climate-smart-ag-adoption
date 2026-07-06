/* BEGIN */

* Project: lsms gender dynamics
* Created on: June 2025
* Created by: george hyland
* Edited on: 22 july 2025
* Edited by: alj
* Stata v.19.5

* does
		* collapses key variables in ag_sec_19 to prepare for merging
		
* assumes
	* access to raw data 

* TO DO:
	* troubleshoot some unit codes not renaming to strings
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
		label 		define acquire1 1 "HEAD" 2 "WIFE/HUSBAND" 3 "CHILD" 4 "GRANDCHILD" ///
						5 "NIECE/NEPHEW" 6 "FATHER/MOTHER" 7 "SISTER/BROTHER" 8 "SON/DAUGHT-IN-LAW" ///
						9 "BROTHER/SISTER-IN-LAW" 10 "GRANDFATHER/MOTHER" 11 "FATHER/MOTHER-IN-LAW" 12 "OTHER RELATIVE" ///
						13 "SERVEANT OR SERVANT'S RELATIVE" 14 "LODGER/LODGER'S RELATIVE" 15 "OTHER NON-RELATIVE" 16 "OTHER (SPECIFY)"
		label 		values (acquire1 acquire2 useright1 useright2 owner1 owner2 ///
						decmake1 decmake2 decmake3 id_resp) acquire1
		
* keep essential variables
 		keep		y4_hhid gardenid plotid acquire1 acquire2 useright1 useright2 ///
						owner1 owner2 decmake1 decmake2 decmake3 id_resp

* gen unique variables for collapsing
		gen collapse = _n
		
		bysort y4_hhid (collapse): gen row = _n

* collapse y4_hhid
		collapse (mean) acquire1 acquire2 useright1 useright2 ///
						owner1 owner2 decmake1 decmake2 decmake3 id_resp, by(y4_hhid)

************************************************************************
**# 2 - end matter
************************************************************************

* save file
*	isid			y4_hhid gardenid
	*** a problem maybe to deal with later but there are missing values here
	qui: 			compress
	save 			"$export/ag_sec_19_merge", replace
	
* close the log
	log	close

/* END */