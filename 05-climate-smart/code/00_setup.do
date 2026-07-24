************************************************************************
* 00_setup.do
* Project: Climate-Smart Agricultural Adoption
* Purpose: Set up project paths and prepare coding workflow
* Author: Joss Tijerina
* Created: July 2026
************************************************************************

clear all
set more off

************************************************************************
* 1. Project folder
************************************************************************

global project "C:/Users/tijer/git/UROC/climate-smart-ag-adoption"

************************************************************************
* 2. Project subfolders
************************************************************************

global cs_code   "$project/05-climate-smart/code"
global cs_docs   "$project/05-climate-smart/docs"
global cs_logs   "$project/05-climate-smart/logs"
global cs_output "$project/05-climate-smart/output"

************************************************************************
* 3. Data folders
* Note: raw LSMS-ISA data should stay outside GitHub
************************************************************************

global raw_data   "C:/Users/tijer/git/UROC/lsms_raw_data"
global clean_data "$project/05-climate-smart/clean-data"


************************************************************************
* 3.1 Existing AIDE Lab Ethiopia data
************************************************************************

* Read-only source location for existing AIDE Lab data
global aide_data ///
    "C:/Users/tijer/OneDrive - University of Arizona/AIDE LAB/Michler, Jeffrey David - (jdmichler)'s files - weather_and_agriculture"

* Final appended Ethiopia dataset
global eth_allrounds ///
    "$aide_data/lsms_gender_data/03-regression_data/eth_allrounds.dta"
	
	
************************************************************************
* 4. Quick check
************************************************************************

display "Climate-smart project setup loaded."
display "Project folder: $project"
display "Ethiopia source file: $eth_allrounds"

capture confirm file "$eth_allrounds"

if _rc {
    display as error "The appended Ethiopia dataset was not found."
    display as error "Check this path: $eth_allrounds"
    exit 601
}

display as result "The appended Ethiopia dataset was found."