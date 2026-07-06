* Project: lsms gender
* Created on: oct 2025
* Created by: jt
* Edited on: 7 april 2026
* Edited by: jt
* Stata v.19.5

* does
	* inputs wave4 dataset for post planting parcel ownership data
	* cleans up gendered plot owner variables 
	* outputs file containing defacto owners, dejure owners, tenure, beqth
		
* assumes
	* access to raw data 

* TO DO:
	* DONE !!
	

************************************************************************
**# 0 - setup
************************************************************************

* define paths
	global	root 	"$data/raw_lsms_data/ethiopia/wave_4/raw"
	global	export 	"$data/lsms_gender_data/01-refined_data/ethiopia/wave_4"
	global	logout 	"$data/lsms_gender_data/01-refined_data/ethiopia/logs"
	
* open log 
	cap		log		close
	log		using	"$logout/sect2_pp_w4", append
	

************************************************************************
**# 1 - clean data
************************************************************************

* load data
		use			"$root/sect2_pp_w4", clear

* rename variables
	rename		(s2q01a s2q05 s2q06 s2q07_1 s2q07_2 s2q03 s2q04b_1 s2q04b_2 s2q04b_3 ///
					s2q04b_4 s2q08 s2q09_1 s2q09_2 ) ///
					(mgmt1 tenure collat defa1 defa2 title deju1 deju2 deju3 deju4 ///
					 beqth beq1 beq2)

* recode yes no
	lab			define yesno 0 "no" 1 "yes"
/*	
* Note to self: the two functions below do the same thing, second one is a loop
	replace		collat	= 0 if	collat == 2
	replace		title	= 0 if	title == 2
	replace		beqth	= 0 if	beqth == 2
	
	lab			value collat yesno
	lab			value title yesno
	lab			value beqth yesno
	
*/
	
	local		ctb collat title beqth
	
	foreach 		v of varlist `ctb' {
		replace			`v' = 0 if `v' == 2
		lab				value `v' yesno 
	}
	
	format 		parcel_id %12.0f
	
* keep essential variables
 	keep		holder_id household_id parcel_id mgmt1 tenure ///
					defa1 defa2 deju1 deju2 deju3 deju4 ///
					ea_id

		
************************************************************************
**# 2 - end matter
************************************************************************

* save file
	qui: 			compress
	isid			holder_id parcel_id
	save 			"$export/sect2_pp_w4", replace
	
* close the log
	log	close

/* END */