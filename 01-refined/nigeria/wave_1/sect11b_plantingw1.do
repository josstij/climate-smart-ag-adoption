* Project: lsms gender
* Created on: sep 2025
* Created by: ns
* Edited on: 1 dec 2025
* Edited by: ns
* Stata v.18.5

* does
		* gets manager 1 from sect11a_planting
		* merges mgmt 1 into sect11b_planting
		* cleans up owner, manager and certificate variable 
		
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
	log 		using 	"$logout/sect11b_plantingw1", append

	
************************************************************************
**# 1 - clean data for mgmt1 (sect11a1_plantingw1)
************************************************************************

* load data
	use			"$root/sect11a1_plantingw1", clear

* rename variables
	rename		s11aq6 		mgmt1
	
	
************************************************************************
**# 2 - merge in defa, deju and manager (sect11b_plantingw1)
************************************************************************

* merge data
	merge 1:1	hhid plotid using "$root/sect11b_plantingw1"

* drop mgmt1 is empty
	drop		if mgmt1 == .
	drop 		_merge
	*** drop 173 plots
	
* generate other mgmt variables
	gen			mgmt2 = s11bq8a
	gen			mgmt3 = s11bq8b
	gen			mgmt4 = s11bq8c
	gen			mgmt5 = s11bq8d
	
* generate de facto owner 1
	gen 		defa1 = s11bq2 if s11bq11 == 1 | s11bq12 == 1
	
* generate de facto owner 2 & 3
	gen			defa2 = s11bq14a
	gen			defa3 = s11bq14b
	gen			defa4 = s11bq14c
	
* generate tenure and de jure owner
	gen			tenure = s11bq4
	gen			deju1 = s11bq6 if tenure == 1
	
	lab var		defa1 "Who in hh has the right to sell this [PLOT] or use it as collateral?"
	lab var		defa2 "Who in hh has the right to sell this [PLOT] or use it as collateral?"	
	
* replace ID 0 with missing since no indiv = 0
	replace		deju1 = . if deju1 == 0

	forvalues i = 1/5 {
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
 	keep		zone state lga sector ea hhid plotid tenure deju1 defa* mgmt*
	
* reorder
	order		zone state lga sector ea hhid plotid tenure deju1 defa1 defa2 ///
					defa3 defa4 mgmt1 mgmt2 mgmt3 mgmt4
							
* save file
	qui: 		compress
	isid		hhid plotid
	save 		"$export/sect11b_plantingw1", replace
	
* close the log
	log	close

/* END */