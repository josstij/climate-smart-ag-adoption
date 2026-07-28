* Project: lsms csa
* Created on: july 2026
* Created by: jt
* Edited on: july 2026
* Edited by: jt
* Stata v.19.5

* does
	* identifies raw Ethiopia variables for explanatory domains
	* documents survey questions and response coding by wave
	* audits observation levels and merge identifiers
	* evaluates cross-wave comparability
	
* assumes
	* raw Ethiopia ESS files are available
	* 00_setup.do defines the project and raw-data paths


	clear 	all
	set 	more off
	cap 	log close _all


************************************************************************
**# 0 - setup
************************************************************************

* load project setup
	do		"C:/Users/tijer/git/UROC/climate-smart-ag-adoption/05-climate-smart/code/00_setup.do"

* define output path
	global	logout		"$cs_logs"

* open log
	log		using		"$logout/domain_variable_inventory.log", ///
				replace text
				
				
************************************************************************
**# 1 - wave 4 candidate source files
************************************************************************

* household and labor
	* sect1_hh_w4.dta		household roster
	* sect4_hh_w4.dta		labor and time use

* economic
	* sect11_hh_w4.dta		household assets
	* sect12a_hh_w4.dta		nonfarm-enterprise participation
	* sect12b1_hh_w4.dta		nonfarm-enterprise roster
	* sect12b2_hh_w4.dta		nonfarm-enterprise barriers
	* sect15a_hh_w4.dta		credit access and constraints
	* sect15b_hh_w4.dta		loan details

* institutional
	* sect11b1_hh_w4.dta		mobile-phone roster
	* sect11b2_hh_w4.dta		mobile ownership and operation
	* sect7_pp_w4.dta		extension and advisory services

* climate and risk
	* sect9_hh_w4.dta		household shocks
	
	
************************************************************************
**# 2 - wave 1 institutional candidates
************************************************************************

* extension-program participation
	* domain: institutional
	* component: extension access
	* questionnaire: post-planting agriculture
	* section: 7
	* question: does the holder participate in the extension program?
	* observation level: holder
	* proposed variable: extension_access
	* proposed barrier: no_extension
	* raw variable: pending confirmation
	* cross-wave comparability: pending
	
	use		"raw-data"
	