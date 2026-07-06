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
* 4. Quick check
************************************************************************

display "Climate-smart project setup loaded."
display "Project folder: $project"