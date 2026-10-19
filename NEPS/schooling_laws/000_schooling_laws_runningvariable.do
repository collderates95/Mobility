/*******************************************************************************
					CREATING RUNNING VARIABLES
*******************************************************************************/

use "${data}\schooling_laws_all.dta", clear


/*
- cutoff date needs to be adjusted by one day 
		- right now: e.g. 01July1970, while statutory cutoff is 30 June1970
		- Correction by subtracting one day -> identifes June as cutoff month
*/
 
replace cut = cut-1


*gen cutoff variables
gen cutm=month(cut) 
gen cuty=year(cut)
gen cut_ =ym(cuty, cutm)
format cut_ %tm

* create running variable on monthly basis
gen run = bdate_ - cut_ 
replace run=run-en_size if run>=en_size/2+1 & run<=(en_size) 
tab run, mis
label var run "running variable (distance to cutoff)"


** create after dummy
gen after = run > 0
label var after "dummy for enrolment after cutoff"


* identify week of cutoff day
gen cutw = week(cut)
gen cutoff_week = yw(cuty,cutw)
format %tw cutoff_week

save "${results}\schooling_laws_run.dta", replace
