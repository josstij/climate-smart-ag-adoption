* Project: lsms gender
* Created on: sep 2025
* Created by: ns
* Edited on: 3 march 2026
* Edited by: ns
* Stata v.18.5

* does
		* cleans dataset for wave 2 pp 11b1q6a
		* cleans up owner and other managers
		
* assumes
		* access to raw data 

* TO DO:
		* done

************************************************************************
**# 0 - setup
************************************************************************

* define paths
	global		root 	"$data/raw_lsms_data/nigeria/wave_2/raw"
	global		export 	"$data/lsms_gender_data/01-refined_data/nigeria/wave_2"
	global		logout 	"$data/lsms_gender_data/01-refined_data/nigeria/logs"
	
	
* open log 
	cap 		log 	close
	log 		using 	"$logout/sect11b1_plantingw2", append


************************************************************************
**# 1 - clean data
************************************************************************

* load data
	use			"$root/sect11a1_plantingw2", clear

* rename variables
	rename		s11aq6a 	mgmt1
	rename		s11aq6b		mgmt2	
	
	
************************************************************************
**# 2 - clean data
************************************************************************

* merge data
	merge 1:1	hhid plotid using "$root/sect11b1_plantingw2"

* drop mgmt1 is empty
	drop		if mgmt1 == .
	drop 		_merge
	*** (42 observations deleted)
	
* generate other mgmt variables
	gen 		mgmt3 = s11b1q12a		
	gen			mgmt4 = s11b1q12b
	gen 		mgmt5 = s11b1q12c		
	gen			mgmt6 = s11b1q12d
	
* label variables
	forvalues i = 1/6 {
		lab var mgmt`i' "Who in this household manages the plot?"
	}

* generate de facto owner 1	
	gen 		defa1 = s11b1q2 if s11b1q19 == 1 | s11b1q20 == 1
	
* generate de facto owner 2 & 3
	gen			defa2 = s11b1q22a
	gen			defa3 = s11b1q22b
	gen			defa4 = s11b1q22c
	
* generate tenure and de jure owner
	gen			tenure = s11b1q4
	gen			deju1 = s11b1q6a if tenure == 1
	gen 		deju2 = s11b1q6b if tenure == 1
	
	forvalues i = 1/4 {
		lab var		defa`i' "Who in hh has the right to sell this [PLOT] or use it as collateral?"
	}
	
	lab var		tenure	"How was this plot aquired"
	lab var		deju1 "de jure owner 1"	
	lab var		deju2 "de jure owner 2"	
	
	
* replace ID 0 with missing since no indiv = 0
	replace		deju1 = . if deju1 == 0

	forvalues i = 1/6 {
		replace mgmt`i' = . if mgmt`i' == 0
	}
	
	forvalues i = 1/4 {
		replace defa`i' = . if defa`i' == 0
	}

	
************************************************************************
**## 2.1 - fill in missing defa1
************************************************************************

* fill in missing defa1 with defa2
	replace		defa1 = defa2 if defa1 == .

* turn defa2 to missing if it duplicates defa1 value
	replace		defa2 = . if defa1 == defa2

* fill in missing defa1 with defa3
	replace		defa1 = defa3 if defa1 == .

* turn defa3 to missing if it duplicates defa1 value
	replace		defa3 = . if defa1 == defa3

* fill in missing defa1 with defa4
	replace		defa1 = defa4 if defa1 == .

* turn defa4 to missing if it duplicates defa1 value
	replace		defa4 = . if defa1 == defa4

	
************************************************************************
**## 2.2 - fill in missing defa2
************************************************************************

* fill in missing defa2 with defa3
	replace		defa2 = defa3 if defa2 == .

* turn defa3 to missing if it duplicates defa2 value
	replace		defa3 = . if defa2 == defa3

* fill in missing defa2 with defa4
	replace		defa2 = defa4 if defa2 == .

* turn defa4 to missing if it duplicates defa2 value
	replace		defa4 = . if defa2 == defa4


************************************************************************
**## 2.3 - fill in missing defa3
************************************************************************

* fill in missing defa3 with defa4
	replace		defa3 = defa4 if defa3 == .

* turn defa4 to missing if it duplicates defa3 value
	replace		defa4 = . if defa3 == defa4
		
		
************************************************************************
**# 3 - end matter
************************************************************************

* keep essential variables
 	keep		zone state lga sector ea hhid plotid tenure deju* defa* mgmt*
	
* reorder
	order		zone state lga sector ea hhid plotid tenure deju1 deju2 defa1 ///
				defa2 defa3 defa4 mgmt1 mgmt2 mgmt3 mgmt4 mgmt5 mgmt6
							
* save file
	qui: 		compress
	isid		hhid plotid
	save 		"$export/sect11b1_plantingw2", replace
	
* close the log
	log	close

/* END */