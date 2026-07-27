* Project: lsms csa
* Created on: july 2026
* Created by: jt
* Edited on: july 2026
* Edited by: jt
* Stata v.19.5

* does
	* appends CSA outcome files for Ethiopia waves 1–5
	
* assumes
	* csa_w1 through csa_w5 have been created
	
* TO DO:
	* all

************************************************************************
**# 0 - setup
************************************************************************

* load project setup
	do		"C:/Users/tijer/git/UROC/climate-smart-ag-adoption/05-climate-smart/code/00_setup.do"

* define paths
	global	root		"$clean_data/ethiopia"
	global	export		"$clean_data/ethiopia"
	global	logout		"$cs_logs"
	
* open log
	cap		log			close
	log		using		"$logout/append_csa", append
	

************************************************************************
**# 1 - append CSA waves
************************************************************************

* load Wave 1
	use			"$root/wave_1/csa_w1", clear

* append Waves 2–5
	append		using		"$root/wave_2/csa_w2" ///
							"$root/wave_3/csa_w3" ///
							"$root/wave_4/csa_w4" ///
							"$root/wave_5/csa_w5"


************************************************************************
**# 2 - check appended data
************************************************************************

* check observations by wave
	tab			wave, missing

* check total observations
	count

* confirm field-wave identifiers are unique
	isid		wave holder_id parcel_id field_id

* check outcome availability by wave
	tabstat		any_csa csa_count_obs csa_complete, ///
				by(wave) statistics(n mean min max)
				
				
************************************************************************
**# 3 - save appended data
************************************************************************

* sort appended data
	sort		wave holder_id parcel_id field_id

* order variables
	order		wave holder_id parcel_id field_id ///
				csa_irr csa_seed csa_soil csa_cons ///
				csa_n_obs csa_count_obs any_csa ///
				csa_complete csa_count any_csa_complete

* save appended CSA data
	save		"$export/csa_allwaves", replace

* close log
	log			close
	
	