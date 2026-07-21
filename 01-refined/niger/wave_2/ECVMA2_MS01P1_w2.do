* Project: lsms gender
* Created on: May 2026
* Created by: js 
* Edited on: 8 July 2026
* Edited by: jdm
* Stata v.19.5

* does
	* inputs wave 2 individual roster
	* cleans up demographic variables (sex, age, edu, etc.)
	* outputs cleaned individual roster

* assumes
	* access to raw data

* TO DO:
	* complete 
	
	
************************************************************************
**# 0 - setup
************************************************************************

* define paths
	global	root 	"$data/raw_lsms_data/niger/wave_2/raw"
	global	export 	"$data/lsms_gender_data/01-refined_data/niger/wave_2"
	global	logout 	"$data/lsms_gender_data/01-refined_data/niger/logs"
	
* open log 
	cap		log		close
	log		using	"$logout/ecvma2_ms01p1_w2", append
	
	
************************************************************************
**# 1 - clean data
************************************************************************

* load demographic data
	use				"$root/ECVMA2_MS01P1.dta", clear
		
* rename variables
	rename			MS01Q01 sex 	
	rename 			MS01Q02 relate  
	rename 			MS01Q06A age     
	rename 			MS01Q15 mrry    
	rename 			MS01Q21A away    
	rename 			MS01Q0 indiv	

	rename 			GRAPPE grappe
	rename 			MENAGE menage
	rename 			EXTENSION extension
				
* generate household identifier
	gen				hid = (grappe * 100) + menage
	gen 			hid2 = (grappe * 10000) + (menage * 100) + extension

* keep essential variables
 	keep			hid hid2 indiv relate sex age away mrry grappe menage extension
		
* label variables
	lab var			hid	"Household Identifier, wave 1"
	lab var			hid2 "Household Identifier, wave 2"
	lab var 		grappe "Cluster Number"
	lab var 		menage "Household ID"
	lab var 		indiv "ID code"
	lab var 		sex "Sex"
	lab var 		relate "Relationship to head"
	lab var 		age "Age in years"
	lab var 		mrry "Marital status"
	lab var 		away "Away from household"
	lab var 		extension "Extension"

* define value labels
	lab def			sex_lbl 1 "Male" 2 "Female"
	lab def			relate_lbl 1 "Household head" 2 "Spouse" 3 "Child" 4 "Parent" ///
						5 "Grandchild" 6 "Grandparent" 7 "Sibling" 8 "Step child" ///
						9 "Nephew" 10 "Cousin" 11 "Brother-in-law,sister-in-law" ///
						12 "Father-in-law,mother-in-law" ///
						13 "Other relative of head or spouse" ///
						14 "Other non related person(not related)" ///
						15 "Domestic or relative of domestic" 99 "Missing"
	lab def			mrry_lbl 1 "Never married" 2 "Monogamous marriage" ///
						3 "Polygamous marriage" 4 "Widow(er)" 5 "Divorced" ///
						6 "Separated" 9 "don't know"
	lab def			away_lbl 0 "Never absent" 999 "Missing"

* apply value labels
	lab val 		sex sex_lbl
	lab val 		relate relate_lbl
	lab val 		mrry mrry_lbl
	lab val 		away away_lbl
	
	
************************************************************************
**# 2 - end matter
************************************************************************

* save file
	isid			hid2 indiv grappe
	qui: 			compress
	save 			"$export/ecvma2_ms01p1_w2", replace
	
* close the log
	log	close

/* END */	
