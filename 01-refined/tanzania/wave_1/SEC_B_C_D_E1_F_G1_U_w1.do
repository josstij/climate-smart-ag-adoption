* Project: lsms gender
* Created on: may 2026
* Created by: ns
* Edited on: 10 july 2026
* Edited by: jdm
* Stata v.18.5

* does
	* finds some of the demographic variables


* assumes
		* access to raw data

* TO DO:
		* done


************************************************************************
**# 0 - setup
************************************************************************

* define paths
	global			root 	"$data/raw_lsms_data/tanzania/wave_1/raw"
	global			export 	"$data/lsms_gender_data/01-refined_data/tanzania/wave_1"
	global			logout 	"$data/lsms_gender_data/01-refined_data/tanzania/logs"

* open log
	cap		log		close
	log				using 	"$logout/SEC_B_C_D_E1_F_G1_U_w1", append


************************************************************************
**# 1 - clean data for SEC_1A_ALL
************************************************************************

* load data
	use				"$root/SEC_B_C_D_E1_F_G1_U", clear

* gen variables
	rename			sbq2 age
	rename			sbq4 sex
	rename			sbq5 relate
	rename			sbq8 away
	rename			sbq18 mrry
	rename			scq2 edu_yesno
	rename			scq6 edu
	rename			seq4 farm
	rename			seq10 nfe
	rename			seq16 wage


************************************************************************
**# 2 - end matter
************************************************************************

* keep
	keep			hhid sbmemno age sex relate away mrry farm edu_yesno edu nfe wage

* drop missing
	drop if 		missing(hhid) | missing(sbmemno)

* save file
	qui:			compress
	isid			hhid sbmemno
	save			"$export/SEC_B_C_D_E1_F_G1_U_w1", replace

* close the log
	log				close

/* END */


