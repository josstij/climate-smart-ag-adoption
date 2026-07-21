* Project: lsms gender
* Created on: May 2026
* Created by: js
* Edited on: 8 July 2026
* Edited by: jdm
* Stata v.19.5

* does
	* inputs wave 2 agricultural parcel data
	* cleans up gendered manager and owner variables (mgmt1, deju1, deju2)
	* no defa owner
	* outputs cleaned parcel data

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
	log				using	"$logout/ecvma2_as1p1_w2", append


************************************************************************
**# 1 - clean data
************************************************************************

* load data
	use				"$root/ECVMA2_AS1P1.dta", clear
		
* rename variables
	rename			AS01Q14 tenure
	
* de jure owners (from the title document)
* AS01Q15 values 1-4 are valid title documents
	gen				deju1   = AS01Q17A if inlist(AS01Q15, 1, 2, 3, 4)
	gen				deju2   = AS01Q17B if inlist(AS01Q15, 1, 2, 3, 4)
	
* manager (who currently operates it)
	rename			AS01Q45 mgmt1
	
	rename			AS01Q01 field_id
	rename			AS01Q03 parcel_id

* lowercase identification variables
	rename			GRAPPE grappe
	rename			MENAGE menage
	rename			EXTENSION extension

* generate household identifier
	gen				hid = (grappe * 100) + menage
	gen				hid2 = (grappe * 10000) + (menage * 100) + extension

* replace invalid IDs with missing
	replace			deju1 = . if deju1 == 0
	replace			deju2 = . if deju2 == 0
	replace			mgmt1 = . if mgmt1 == 0 | mgmt1 == 98 | mgmt1 == 99

* keep essential variables
	keep			hid hid2 grappe menage extension parcel_id field_id tenure ///
					deju1 deju2 mgmt1 
					
* apply english variable labels
	lab var			hid "Household Identifier, wave 1"
	lab var			hid2 "Household Identifier, wave 2"
	lab var			grappe "Cluster number"
	lab var			menage "Household ID"
	lab var			extension "Extension number"
	lab var			parcel_id "Parcel number"
	lab var			field_id "Field number"
	lab var			tenure "Tenure status of the parcel"
	lab var			deju1 "First name on the title document"
	lab var			deju2 "Second name on the title document"
	lab var			mgmt1 "Person who currently operates the parcel"

* apply english value labels for tenure
	lab def			tenure_lbl 1 "Owned" 2 "Co-owned" 3 "Rented" 4 "Mortgaged" ///
						5 "Borrowed" 6 "Other" 9 "Missing"
	lab val			tenure tenure_lbl


************************************************************************
**# 2 - end matter
************************************************************************

* save file
	isid			hid2 parcel_id field_id
	qui:			compress
	save			"$export/ecvma2_as1p1_w2", replace
	
* close the log
	log				close

/* END */