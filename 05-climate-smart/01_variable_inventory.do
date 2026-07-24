* Project: gender
* Created on: July 2026
* Created by: jmt
* Stata v.19.5





************************************************************************
* Project: Climate-smart agriculture adoption
* File: 01_variable_inventory.do
* Purpose: Review existing Ethiopia variables
************************************************************************

	clear all
	set more off

	* Establish project paths
	do "C:/Users/tijer/git/UROC/climate-smart-ag-adoption/projectdo.do"

	* Open final AIDE Lab Ethiopia dataset
	use "$eth_allrounds", clear

	* Confirm dataset structure
	describe
	tab wave

	isid holder_id parcel_id field_id wave