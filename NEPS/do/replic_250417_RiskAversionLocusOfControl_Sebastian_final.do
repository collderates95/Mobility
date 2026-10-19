/*******************************************************************************
This file generates the results of column 5 from Table A.5



*******************************************************************************/ 

*** Globals ****
global RuralVariable i.RuralNEPSMZ


********************************************************************************
* Step 1: Merge sample with risk affinity data
********************************************************************************
use "$results\C9_Combined_Full_Panel_final.dta", clear
keep if inrange(yob, 1945, 1964)

* Make it Cross - Sectional Again
duplicates drop ID_t, force

*** joinby
joinby ID_t using "$results/RiskAndLocus.dta", unmatched(both) 
tab _merge
gen missing = _merge ==1 // for later regression on Missings
drop if _merge == 2 
count if w_t4_cal != 0 // 5,259 obs.
count if w_t4_cal != 0 & missing != 1 // 4,147 obs.

/*******************************************************************************
	STEP 2 - standardize skills within estimation sample
*******************************************************************************/


foreach var in zmRiskAffGeneral   { 
	center `var' [aw=w_t4_cal], generate(z`var') standardize
	drop `var'
}

/*******************************************************************************
	STEP 3 - produce estimation results	(column 5)
*******************************************************************************/

foreach var of varlist zzmRiskAffGeneral {  

gen missing_`var' = `var'== .

*Panel A
	areg `var' C9 i.bula [aweight = w_t4_cal], robust absorb(cohort)
	eststo c0_`var'
	qui sum `var' [aw=w_t4_cal] if e(sample)
	scalar Mean = r(mean)
	qui estadd scalar Mean

*Panel B	
	areg missing_`var' C9 i.bula [aweight = w_t4_cal], robust absorb(cohort)
	eststo miss_`var'
	qui sum missing_`var' if e(sample)
	scalar Mean = r(mean)
	qui estadd scalar Mean	
	
}
esttab c0_* using "$results\C9_RiskAndLOC.csv", keep(C9) cells(b(fmt(3) star) se(par)) scalar(Mean) starlevels(* 0.1 ** 0.05 *** 0.01) stardetach title("TWFE Regressions Risk on C9 - Without Controls") nodepvars replace // 

esttab miss_* using "$results\C9_RiskAndLOC.csv", keep(C9) cells(b(fmt(3) star) se(par)) scalar(Mean) starlevels(* 0.1 ** 0.05 *** 0.01) stardetach title("Missing") nodepvars append 

eststo clear

