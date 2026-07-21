* Project: lsms gender
* Created on: may 2026
* Created by: ns
* Edited on: 10 july 2026
* Edited by: jdm
* Stata v.18.5

* does

* assumes
		* access to raw data

* TO DO:
		* done


************************************************************************
**# 0 - setup
************************************************************************

* define paths
	global			root 	"$data/raw_lsms_data/tanzania/wave_7/raw"
	global			export 	"$data/lsms_gender_data/01-refined_data/tanzania/wave_7"
	global			logout 	"$data/lsms_gender_data/01-refined_data/tanzania/logs"

* open log
	cap		log		close
	log				using 	"$logout/AG_SEC_3A_w7", append


************************************************************************
**# 1 - clean data for AG_SEC_3A
************************************************************************

* load data
	use				"$root/AG_SEC_3A", clear

* gen defa var
	rename			ag3a_29_1 defa1
	rename			ag3a_29_2 defa2

* gen deju var
	rename			ag3a_28a tenure
	gen				deju1 = defa1 if tenure != 3 & tenure != .
	gen				deju2 = defa2 if tenure != 3 & tenure != .

* gen manager var
	rename			ag3a_08b_1 mgmt1
	rename			ag3a_08b_2 mgmt2
	rename			ag3a_08b_3 mgmt3


* label var
	lab var			deju1 	"de jure owner 1"
	lab var			deju2 	"de jure owner 2"

	rename			y5_hhid hhid


************************************************************************
**# 2.2 - clean string and numeric IDs
************************************************************************

* Clean string variables and IDs
	foreach v of varlist deju* defa* mgmt* {
	    capture confirm string variable `v'
		if _rc == 0 {
			replace			`v' = "" if `v' == "MISSING" | `v' == "99" | ///
								`v' == "0" | `v' == "992"
	        destring `v', replace
		}

	    capture confirm numeric variable `v'
		if _rc == 0 {
			replace			`v' = . if `v' == 99 | `v' == 0 | `v' == 992
		}
	}
************************************************************************
**# 3 - end matter
************************************************************************

* keep essential variables
	keep			hhid plot_id tenure deju* defa* mgmt*

* reorder
	order				hhid plot_id tenure deju1 deju2 defa1 ///
							defa2 mgmt1 mgmt2 mgmt3

* drop missing
	drop			if 			missing(hhid) | missing(plot_id)

* save file
	qui:			compress
	isid			hhid plot_id
	save			"$export/AG_SEC_3A_w7", replace

* close the log
	log				close

/* END */



