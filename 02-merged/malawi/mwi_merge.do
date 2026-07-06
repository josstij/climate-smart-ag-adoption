* Project: lsms gender
* Created on: April 1 2026
* Created by: ns
* Edited on: 20 April 2026
* Edited by: ns,js
* Stata v.18.5


************************************************************************
**# 0 - setup
************************************************************************

    loc dofile = "$code/02-merged"

	
************************************************************************
**# 1 - run ethiopia merge .do files
************************************************************************


************************************************************************
**# 2 - run malawi merge .do files
************************************************************************

************************************************************************
**## 2.1 - merge individual files together
************************************************************************

* define the path
	local 		mwi "`dofile'/malawi"

* get all .do files starting with "mal_"
	local f : 	dir "`mwi'" files "mal_*.do"

* loop through files, but SKIP the append file for now
	foreach file of local f {
    
    * check if the file is the 'appended' one; if so, skip it
		if "`file'" == "mal_append.do" {
			continue
		}
    
		display "Currently running merged file: `file'"
        do "`mwi'/`file'"
}

************************************************************************
**## 2.2 - append wave files together
************************************************************************

*display
	display 	"Final Step: Running the appended file..."

* Explicitly run the specific append file
	do 			"`mwi'/mal_append.do"


************************************************************************
**# 3 - run mali merge .do files
************************************************************************


************************************************************************
**# 4 - run niger merge .do files
************************************************************************


************************************************************************
**# 5 - run nigeria merge .do files
************************************************************************
/*
************************************************************************
**## 5.1 - merge individual files together
************************************************************************

* define the path
	local 		nga "`dofile'/nigeria"

* get all .do files starting with "nga_"
	local f : 	dir "`nga'" files "nga_*.do"

* loop through files, but SKIP the append file for now
	foreach file of local f {
    
    * check if the file is the 'appended' one; if so, skip it
		if "`file'" == "nga_appended.do" {
			continue
		}
    
		display "Currently running merged file: `file'"
    do "`nga'/`file'"
}

************************************************************************
**## 5.2 - append wave files together
************************************************************************

*display
	display 	"Final Step: Running the appended file..."

* Explicitly run the specific append file
	do 			"`nga'/nga_append.do"

	*/
************************************************************************
**# 6 - run tanzania merge .do files
************************************************************************


************************************************************************
**# 7 - run uganda merge .do files
************************************************************************

/* END */