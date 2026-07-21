* Project: lsms gender
* Created on: May 2026
* Created by: js
* Edited on: 8 July 2026
* Edited by: jdm
* Stata v.19.5

* does
	* inputs wave 2 education module
	* cleans up education variable (edu)
	* outputs cleaned education roster

* assumes
	* access to raw data

* TO DO:
	* complete


************************************************************************
**# 0 - setup
************************************************************************

* define paths
	global			root 	"$data/raw_lsms_data/niger/wave_2/raw"
	global			export 	"$data/lsms_gender_data/01-refined_data/niger/wave_2"
	global			logout 	"$data/lsms_gender_data/01-refined_data/niger/logs"
	
* open log
	cap		log		close
	log				using	"$logout/ecvma2_ms02p1_w2", append


************************************************************************
**# 1 - clean data
************************************************************************

* load data
	use				"$root/ECVMA2_MS02P1.dta", clear
		
* rename variables
	rename			MS02Q23 edu
	rename			MS02Q00 indiv

	rename			GRAPPE grappe
	rename			MENAGE menage
	rename			EXTENSION extension
				
* generate household identifier
	gen				hid = (grappe * 100) + menage
	gen				hid2 = (grappe * 10000) + (menage * 100) + extension

* keep essential variables
	keep			hid hid2 indiv edu grappe menage extension
	
* label variables
	lab var			hid	"Household Identifier, wave 1"
	lab var			hid2 "Household Identifier, wave 2"
	lab var			indiv  "Individual ID"
	lab var			edu    "Education"
	lab var			grappe "Cluster Number"
	lab var			menage "Household ID"
	lab var			extension "Household extension"

* define value labels
	lab def			edu_lbl 1 "Preschool" 2 "Primary" 3 "Secondary first cycle-general" ///
						4 "Secondary first cycle technical & professional" 5 "Secondary second cycle general" ///
						6 "Secondary second cycle technical& professional" 7 "Superior" 9 "DK"

* apply value labels
	lab val			edu edu_lbl


************************************************************************
**# 2 - end matter
************************************************************************

* save file
	isid			hid2 indiv
	qui:			compress
	save			"$export/ecvma2_ms02p1_w2", replace
	
* close the log
	log				close

/* END */
