********************************************************************************
* 	Table A.6 (column 5) - risk affinity
********************************************************************************

use "$results\ssa_panel_obs1_neu.dta", clear

estimates drop _all

* define globals
global instr i.after_week
global lin_plain run_week i.after_week#c.run_week 



*********************Sample restriction***********************************************

keep if inrange(yob,1945,1964)
keep if w_t4_cal != 0 
drop if inlist(run_week,-1,0,1,2)


/*******************************************************************************
	STEP 1 - standardize skills within estimation sample
*******************************************************************************/


foreach var in zmRiskAffGeneral   { 
	center `var' [aw=w_t4_cal], generate(z`var') standardize
	drop `var'
}


cap erase "${results}\ssa_locrisk_neu_$date.csv"




/*******************************************************************************
	STEP 2 - produce estimation results	(column 5)
*******************************************************************************/
foreach var of varlist zzmRiskAffGeneral {  

gen missing_`var' = `var'== .

qui ivreg2 `var' $instr $lin_plain [aw=w_t4_cal],  robust partial($lin_plain)  
estimates store r_`var'
qui sum `var' [aw=w_t4_cal] if e(sample)
scalar y_mean=r(mean) 
qui estadd scalar y_mean   

qui ivreg2 missing_`var' $instr $lin_plain [aw=w_t4_cal],  robust partial($lin_plain)  
estimates store m_`var'
qui sum missing_`var' if e(sample)
scalar y_mean=r(mean) 
qui estadd scalar y_mean    
 
}

esttab r_*  using "${results}\ssa_locrisk_neu_$date", append scsv keep(1.after_week) cells(b(fmt(3) star) se(par) p) scalar(y_mean) starlevels(* 0.1 ** 0.05 *** 0.01) stardetach title("Donut - main results") nodepvars

esttab m_*  using "${results}\ssa_locrisk_neu_$date", append scsv keep(1.after_week) cells(b(fmt(3) star) se(par) p) scalar(y_mean) starlevels(* 0.1 ** 0.05 *** 0.01) stardetach title("Donut - selection into participation") nodepvars

