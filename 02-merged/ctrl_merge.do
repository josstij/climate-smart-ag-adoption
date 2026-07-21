* Project: lsms gender
* Created on: nov 2025
* Created by: ns
* Edited on: 7 april
* Edited by: jdm
* Stata v.18.5

* does
	* Executes all country specific merge .do files
	* outputs finished houshold data sets ready to merge with weather
		
* assumes
	* wave-specific .do files
		
* TO DO:
	* done
    
    
************************************************************************
**# 0 - setup
************************************************************************

    loc dofile = "$code/02-merged"

	
************************************************************************
**# 1 - run ethiopia merge .do files
************************************************************************

* define the path
	local 		eth "`dofile'/ethiopia"

* get all .do files starting with "eth_"
	local f : 	dir "`eth'" files "eth_*.do"

* loop through files, but SKIP the append file for now
	foreach file of local f {
		if "`file'" == "eth_append.do" {
			continue
		}
		display "Currently running merged file: `file'"
		do "`eth'/`file'"
	}

* append wave files together
	display 	"Final Step: Running the appended file..."
	do 			"`eth'/eth_append.do"

************************************************************************
**# 2 - run malawi merge .do files
************************************************************************

* define the path
	local 		mwi "`dofile'/malawi"

* get all .do files starting with "mwi_"
	local f : 	dir "`mwi'" files "mwi_*.do"

* loop through files, but SKIP the append file for now
	foreach file of local f {
		if "`file'" == "mwi_append.do" {
			continue
		}
		display "Currently running merged file: `file'"
		do "`mwi'/`file'"
	}

* append wave files together
	display 	"Final Step: Running the appended file..."
	do 			"`mwi'/mwi_append.do"

	
************************************************************************
**# 3 - run mali merge .do files
************************************************************************


************************************************************************
**# 4 - run niger merge .do files
************************************************************************

* define the path
	local 		ngr "`dofile'/niger"

* get all .do files starting with "ngr_"
	local f : 	dir "`ngr'" files "ngr_*.do"

* loop through files, but SKIP the append file for now
	foreach file of local f {
    
    * check if the file is the 'appended' one; if so, skip it
		if "`file'" == "ngr_appended.do" {
			continue
		}
    
		display "Currently running merged file: `file'"
    	do "`ngr'/`file'"
	}

*display
	display 	"Final Step: Running the appended file..."

* Explicitly run the specific append file
	do 			"`ngr'/ngr_append.do"


************************************************************************
**# 5 - run nigeria merge .do files
************************************************************************

* define the path
	local 		nga "`dofile'/nigeria"

* get all .do files starting with "nga_"
	local f : 	dir "`nga'" files "nga_*.do"

* loop through files, but SKIP the append file for now
	foreach file of local f {
    
    * check if the file is the 'appended' one; if so, skip it
		if "`file'" == "nga_append.do" {
			continue
		}
    
		display "Currently running merged file: `file'"
    do "`nga'/`file'"
}

* append wave files together
	display 	"Final Step: Running the appended file..."
	do 			"`nga'/nga_append.do"

	
************************************************************************
**# 6 - run tanzania merge .do files
************************************************************************

* define the path
	local 		tza "`dofile'/tanzania"

* get all .do files starting with "tza_"
	local f : 	dir "`tza'" files "tza_*.do"

* loop through files, but SKIP the append file for now
	foreach file of local f {
    
    * check if the file is the 'appended' one; if so, skip it
		if "`file'" == "tza_appended.do" {
			continue
		}
    
		display "Currently running merged file: `file'"
		do "`tza'/`file'"
	}

* display
	display 	"Final Step: Running the appended file..."

* Explicitly run the specific append file
	do 			"`tza'/tza_append.do"
	
	
************************************************************************
**# 7 - run uganda merge .do files
************************************************************************


	
	
/* END */