* Project: lsms gender
* Created on: May 2026
* Created by: js
* Edited on: 8 July 2026
* Edited by: jdm
* Stata v.19.5

* does
	* inputs wave 2 labor module
	* cleans up labor variables (farm, nfe, wage)
	* outputs cleaned labor roster

* assumes
	* access to raw data
**# Bookmark #1

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
	log				using	"$logout/ecvma2_ms04p1_w2", append


************************************************************************
**# 1 - clean data
************************************************************************

* load data
	use				"$root/ECVMA2_MS04P1.dta", clear
		
* rename variables
	rename			MS04Q01 farm
	rename			MS04Q02 nfe
	rename			MS04Q03 wage
	rename			MS04Q00 indiv

	rename			GRAPPE grappe
	rename			MENAGE menage
	rename			EXTENSION extension
				
* generate household identifier
	gen				hid = (grappe * 100) + menage
	gen				hid2 = (grappe * 10000) + (menage * 100) + extension

* keep essential variables
	keep			hid hid2 indiv farm nfe wage grappe menage extension
	
* label variables
	lab var			hid	"Household Identifier, wave 1"
	lab var			hid2 "Household Identifier, wave 2"
	lab var			indiv  "Individual ID"
	lab var			farm   "Worked in agriculture last 7 days"
	lab var			nfe    "Worked in non-farm enterprise last 7 days"
	lab var			wage   "Wage/salaried worker"
	lab var			grappe "Cluster Number"
	lab var			menage "Household ID"
	lab var			extension "Household extension"

* define value labels
	lab def			yesno_lbl 1 "Yes" 0 "No" 9 "Missing"

* apply value labels
	lab val			farm yesno_lbl
	lab val			nfe yesno_lbl
	lab val			wage yesno_lbl


************************************************************************
**# 2 - end matter
************************************************************************

* save file
	isid			hid2 indiv
	qui:			compress
	save			"$export/ecvma2_ms04p1_w2", replace
	
* close the log
	log				close

/* END */	
