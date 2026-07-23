* Project: gender
* Created on: July 2026
* Created by: jmt
* Stata v.19.5

* does
	* establishes an identical workspace between users
	* sets globals that define absolute paths
	* serves as the starting point to find any do-file, dataset or output
	* runs all do-files needed for data work. ([!] Eventually)
	* loads any user written packages needed for analysis

* assumes
	* access to all data and code

* TO DO:
	* add all do-files

	
************************************************************************
**# 0 - setup
************************************************************************

* set $pack to 0 to skip package installation
	global 			pack 	0
		
* Specify Stata version in use
    global stataVersion 19.5    // set Stata version
    version $stataVersion


************************************************************************
**## 0.1 - Create user specific paths
************************************************************************

* Define root folder globals
    if `"`c(username)'"' == "jdmichler" {
        global 		code  	"C:/Users/jdmichler/git/AIDELabAZ/lsms-gender"
		global 		data	"C:/Users/jdmichler/OneDrive - University of Arizona/weather_and_agriculture"
    }
	

    if `"`c(username)'"' == "jdmic" {
        global 		code  	"C:/Users/jdmic/git/lsms-gender"
		global 		data	"C:/Users/jdmic/OneDrive - University of Arizona/weather_and_agriculture"
    }
	
    if `"`c(username)'"' == "aljos" {
        global 		code  	"C:/Users/aljos/git/lsms-gender"
		global 		data	"C:/Users/aljos/OneDrive - University of Arizona/weather_and_agriculture/lsms_gender_data"
    }
	
	if `"`c(username)'"' == "tijer" {
        global 		code  	"C:/Users/tijer/git/lsms-gender"
		global 		data	"C:/Users/tijer/OneDrive - University of Arizona/AIDE LAB/Michler, Jeffrey David - (jdmichler)'s files - weather_and_agriculture"
    }
	

	if `"`c(username)'"' == "Nelson" {
        global 		code  	"C:/Users/Nelson/Documents/GitHub/lsms-gender"
		global 		data	"C:/Users/Nelson/University of Arizona/Michler, Jeffrey David - (jdmichler) - weather_and_agriculture"
    }		

	
************************************************************************
**## 0.2 - Check if any required packages are installed:
************************************************************************

* install packages if global is set to 1
if $pack == 1 {
	
	* for packages/commands, make a local containing any required packages 
    * temporarily set delimiter to ; so can break the line
    #delimit ;		
	loc userpack = "blindschemes unique mdesc estout palettes distinct winsor2 
					catplot colrspace coefplot" ;
    #delimit cr
	
	* install packages that are on ssc	
		foreach package in `userpack' {
			capture : which `package', all
			if (_rc) {
				capture window stopbox rusure "You are missing some packages." "Do you want to install `package'?"
				if _rc == 0 {
					capture ssc install `package', replace
					if (_rc) {
						window stopbox rusure `"This package is not on SSC. Do you want to proceed without it?"'
					}
				}
				else {
					exit 199
				}
			}
		}

	* install -xfill and dm89_1 - packages
		net install xfill, 	replace from(https://www.sealedenvelope.com/)
	* update all ado files
		ado update, update

	* set graph and Stata preferences
		set scheme plotplain, perm
		set more off
}

/*
************************************************************************
**# 1 - run household data cleaning .do file
************************************************************************

*	do				"$code/01-refined/ctrl_refined.do"	


	
************************************************************************
**# 2 - run merge .do file
************************************************************************

*	do				"$code/02-merged/ctrl_merge.do"	
	
*/
************************************************************************
**# 3 - run regression .do files
************************************************************************

	
	