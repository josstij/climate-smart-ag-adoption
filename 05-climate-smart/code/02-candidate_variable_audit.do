* Project: lsms csa
* Created on: july 2026
* Created by: jt
* Edited on: july 2026
* Edited by: jt
* Stata v.19.5

* does
	* inspects the final Ethiopia CSA analysis dataset
	* searches for variables needed to construct barrier indices
	* compares variable availability with the harmonized Ethiopia source
	* documents variables that require additional raw-module merges
	
* assumes
	* eth_csa_analysis.dta has been created
	* eth_allrounds.dta is available through 00_setup.do


clear all
set more off
cap log close _all


************************************************************************
**# 0 - setup
************************************************************************

* load project setup
	do		"C:/Users/tijer/git/UROC/climate-smart-ag-adoption/05-climate-smart/code/00_setup.do"

* define paths
	global	root		"$clean_data/ethiopia"
	global	logout		"$cs_logs"

* open log
	log		using		"$logout/candidate_variable_audit.log", ///
				replace text


************************************************************************
**# 1 - inspect final CSA analysis dataset
************************************************************************

* load final analysis data
	use		"$root/eth_csa_analysis", clear

* confirm analysis unit
	isid	wave holder_id parcel_id field_id

* identify dataset being inspected
	display	as result	"=============================================="
	display	as result	"CURRENT ETH_CSA_ANALYSIS DATASET"
	display	as result	"=============================================="


************************************************************************
**# 1.1 - household and labor candidates
************************************************************************

	lookfor		household
	lookfor		member
	lookfor		size
	lookfor		adult
	lookfor		child
	lookfor		dependency
	lookfor		labor
	lookfor		hired


************************************************************************
**# 1.2 - economic candidates
************************************************************************

	lookfor		credit
	lookfor		loan
	lookfor		borrow
	lookfor		subsidy
	lookfor		support
	lookfor		program
	lookfor		asset
	lookfor		livestock
	lookfor		equipment
	lookfor		enterprise
	lookfor		business
	lookfor		nonfarm


************************************************************************
**# 1.3 - institutional candidates
************************************************************************

	lookfor		extension
	lookfor		agent
	lookfor		advice
	lookfor		training
	lookfor		weather
	lookfor		forecast
	lookfor		information
	lookfor		phone
	lookfor		mobile
	lookfor		radio
	lookfor		internet
	lookfor		communication
	lookfor		cooperative


************************************************************************
**# 1.4 - climate and risk candidates
************************************************************************

	lookfor		shock
	lookfor		drought
	lookfor		flood
	lookfor		rainfall
	lookfor		rain
	lookfor		pest
	lookfor		disease
	lookfor		crop loss
	lookfor		conflict
	lookfor		insecurity


************************************************************************
**# 1.5 - land and tenure candidates
************************************************************************

	lookfor		tenure
	lookfor		certificate
	lookfor		title
	lookfor		collateral
	lookfor		transfer
	lookfor		sell
	lookfor		inherit
	lookfor		owner
	lookfor		manager


************************************************************************
**# 1.6 - search candidate variable names
************************************************************************

	foreach pattern in ///
		hhsize hh_size hhmem ///
		credit loan borrow subsidy program ///
		asset livestock equipment ///
		nfe enterprise business ///
	