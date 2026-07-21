* Project: lsms gender
* Created on: oct 2025
* Created by: ns
* Edited on: 8 oct 2025
* Edited by: ns
* Stata v.18.5

* does
		* cleans dataset for wave 4 s11b1
		* cleans up owner variables

* assumes
		* access to raw data 

* TO DO:
		* done!

	
************************************************************************
**# 0 - setup
************************************************************************

* define paths
	global root 	"$data/raw_lsms_data/nigeria/wave_4/raw"
	global export 	"$data/lsms_gender_data/01-refined_data/nigeria/wave_4"
	global logout 	"$data/lsms_gender_data/01-refined_data/nigeria/logs"
	
* open log 
	cap		log			close
	log		using		"$logout/sect11b1_plantingw4", append
	

************************************************************************
**# 1 - clean data for mgmt1 (sect11a1_plantingw4)
************************************************************************

* load data
	use			"$root/sect11a1_plantingw4", clear

* gen variables
	gen			mgmt1 = s11aq6a 
	gen 		mgmt2 = s11aq6b 
	gen 		mgmt3 = s11aq6c 
	gen 		mgmt4 = s11aq6d 
	
	
************************************************************************
**# 2 - clean data for owners (sect11b1_plantingw4)
************************************************************************

* merge data
	merge 1:1	hhid plotid using "$root/sect11b1_plantingw4"

* drop mgmt1 is empty
	drop		if mgmt1 == .
	drop 		_merge
	*** (2,719 observations deleted)
		
* label variables
	forvalues i = 1/4 {
		lab var mgmt`i' "WHO IN THE HH MANAGES THIS [PLOT]? (ID CODE 1)"
	}
	
* generate de facto owner 1	
	gen 		defa1 = s11b1q2 if s11b1q19 == 1 | s11b1q20 == 1
	
* generate de facto owner 2 - 10
	gen			defa2 = s11b1q22_1
	gen			defa3 = s11b1q22_2
	gen			defa4 = s11b1q22_3
	gen			defa5 =	s11b1q22_4
	gen			defa6 =	s11b1q22_5
	gen			defa7 =	s11b1q22_6
	gen			defa8 =	s11b1q22_7
	gen			defa9 =	s11b1q22_8
	gen			defa10 = s11b1q22_9

* generate tenure and de jure owner
	gen			tenure = s11b1q4
	gen			deju1 = s11b1q8b2_1 if tenure == 1
	gen 		deju2 = s11b1q8b2_2 if tenure == 1
	gen			deju3 = s11b1q8b4_1 if tenure == 1
	gen 		deju4 = s11b1q10e_1 if tenure == 1

	
	forvalues i = 1/10 {
		lab var		defa`i' "Who in hh has the right to sell this [PLOT] or use it as collateral?"
	}
	
	lab var		tenure	"How was this plot acquired"
	lab var		deju1	"de jure owner 1"	
	lab var		deju2	"de jure owner 2"	
	lab var		deju3	"de jure owner 3"	
	lab var		deju4	"de jure owner 4"	

	forvalues i = 1/4 {
		replace deju`i' = . if deju`i' == 0
		}

	forvalues i = 1/4 {
		replace mgmt`i' = . if mgmt`i' == 0
	}
	
	forvalues i = 1/10 {
		replace defa`i' = . if defa`i' == 0 
	}

	
************************************************************************
**## 2.1 - fill in missing defa1 - defa10
************************************************************************

* loop over each base variable
	forvalues i = 1/10 {

    * loop over all later variables
		forvalues j = `=`i'+1'/10 {

        * fill missing defa`i' with defa`j'
			replace defa`i' = defa`j' if missing(defa`i')

        * remove duplicates from later variable
			replace defa`j' = . if defa`i' == defa`j'
    }
}

************************************************************************
**# 3 - end matter
************************************************************************

* keep essential variables
	keep		zone state lga sector ea hhid plotid tenure deju* defa* ///
					mgmt*
	
* reorder
	order		zone state lga sector ea hhid plotid tenure deju1 deju2 deju3 deju4 defa1 ///
					defa2 defa3 defa4 defa5 defa6 defa7 defa8 defa9 defa10 ///
					mgmt1 mgmt2 mgmt3 mgmt4 
* save file
	qui: 		compress
	isid		hhid plotid
	save 		"$export/sect11b1_plantingw4", replace
	
* close the log
	log			close

/* END */