* Project: lsms gender
* Created on: mar 2026
* Created by: jdm
* Edited on: 7 apr 2026
* Edited by: jdm
* Stata v.19.5

* does
	* Executes all country specific control .do files
	* outputs finished houshold data sets ready to merge together
		
* assumes
	* wave-specific .do files
		
* TO DO:
	* done
    
    
************************************************************************
**# 0 - setup
************************************************************************

    loc dofile = "$code/01-refined"
	
************************************************************************
**# 1 - run country control .do files
************************************************************************

	do				"`dofile'/malawi/ctrl_mwi.do"
	do				"`dofile'/nigeria/ctrl_nga.do"

	
/* END */