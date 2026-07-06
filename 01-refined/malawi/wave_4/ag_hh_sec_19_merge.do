* Project: lsms gender dynamics
* Created on: July 2025
* Created by: george hyland
* Edited on: 28 July 2025
* Edited by: george hyland
* Stata v.19.5

* does
		* merges hh_sec_19, ag_sec_19

* assumes

* to do
		* merge with 2019_fcs
		* drop vars that don't merge?
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
		use			"$data/refined/wave_4/hh_sec_19", clear

* gen unique variables for collapsing	
		gen collapse = _n
		
		bysort y4_hhid (collapse): gen row = _n
		
* merge data
		merge		m:1 y4_hhid using "$data/refined/wave_4/ag_sec_19_merge"
		
/*		    Result                      Number of obs
    -----------------------------------------
    Not matched                         3,415
        from master                     3,415  (_merge==1)
        from using                          0  (_merge==2)

    Matched                            11,234  (_merge==3)
    -----------------------------------------

*/

* convert unit codes to strings	
		label 		define rename 1 "HEAD" 2 "WIFE/HUSBAND" 3 "CHILD" 4 "GRANDCHILD" ///
						5 "NIECE/NEPHEW" 6 "FATHER/MOTHER" 7 "SISTER/BROTHER" 8 "SON/DAUGHT-IN-LAW" ///
						9 "BROTHER/SISTER-IN-LAW" 10 "GRANDFATHER/MOTHER" 11 "FATHER/MOTHER-IN-LAW" 12 "OTHER RELATIVE" ///
						13 "SERVEANT OR SERVANT'S RELATIVE" 14 "LODGER/LODGER'S RELATIVE" 15 "OTHER NON-RELATIVE" 16 "OTHER (SPECIFY)"
		label 		values (acquire1 acquire2 useright1 useright2 ///
						owner1 owner2 decmake1 decmake2 decmake3 id_resp) rename
						
						
************************************************************************
**# 2 - end matter
************************************************************************

* save file
	qui: 			compress
	save 			"$export/ag_hh_sec_19_merge", replace
	
* close the log
	log	close

/* END */