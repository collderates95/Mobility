*****************Fig A.11 ******************


*************This file creates the raw data for the Figure A.11
*************The figure itself has been created locally based on these numbers.


use "$results\ssa_panel_obs1_neu.dta", clear

********************************************************************************
* 	Create dataset
********************************************************************************

keep if inrange(yob,1945,1964)
keep if w_t4_cal != 0 


* create one dataset per educ. variable
foreach var of varlist aase acadt_filled  {
preserve
keep if inrange(yob,1945,1964)
keep if `var' != .
drop if `var' == -99
gen N=1 
local lab: variable label `var' 

reg `var' run_week [aw=w_t4_cal] if inrange(run_week,-24,0)
predict fit0_`var', xb
predict se0_`var', stdp
reg `var' run_week [aw=w_t4_cal] if inrange(run_week,1,25)
predict fit1_`var', xb
predict se1_`var', stdp

collapse (mean) `var' fit0_`var' fit1_`var' se0_`var' se1_`var' (count) N [aw=w_t4_cal], by(run_week)
label var `var' "`lab'"
gen ci0_hi_`var' = fit0_`var' + 1.96*se0_`var'
gen ci0_lo_`var' = fit0_`var' - 1.96*se0_`var' 

gen ci1_hi_`var' = fit1_`var' + 1.96*se1_`var' 
gen ci1_lo_`var' = fit1_`var' - 1.96*se1_`var' 

gen samp_`var' = 1

save "${results}\temp\educ_by_week_full_`var'.dta", replace
restore
}

use "${results}\educ_by_week_full_aase.dta", clear
local datasets "acadt_filled"
foreach x of local datasets {
	merge 1:1 run_week using "${results}\educ_by_week_full_`x'.dta"
	drop _merge
}
save "${results}\educ_by_week_full_weighted_neu.dta", replace
export excel using "$results\educ_by_week_full_weighted_neu.xls", firstrow(variables) replace


******************Figure A.11 (different style as orig. figure was generated locally)
local word "weighted"
foreach ds of local word {
use "$results\educ_by_week_full_`ds'_neu.dta", clear

** SSA
preserve
keep if samp_aase == 1
twoway scatter aase run_week, color(gs8) || line fit0_aase run_week if inrange(run_week,-24,0), color(gs4%70) clcolor(blue)  || line fit1_aase run_week if inrange(run_week,1,25) , color(gs4%70) clcolor(blue)    ///
		scheme(s1mono) xlabel(-24(4)24) legend(off) yscale(range(6 7)) ylabel(6(0.2)7) xline(0, lcolor(red))  ///
		ytitle("", size(medsmall))       /// 
	    xtitle("Date of birth relative to the cutoff", size(medsmall)) ///
		legend(off) ///
		title("Age at school entry", size(medsmall))  //
graph display, xsize(10) ysize(6)
graph save "${graphs}\aase_$date_full_`ds'_neu", replace
graph export "${graphs}\aase_$date_full_`ds'_neu.pdf", replace
restore


** Academic Track
preserve
keep if samp_acadt_filled == 1
twoway scatter acadt_filled run_week, color(gs8) || line fit0_acadt_filled run_week if inrange(run_week,-24,0), color(gs4%70) clcolor(blue)  || line fit1_acadt_filled run_week if inrange(run_week,1,25) , color(gs4%70) clcolor(blue)    ///
		scheme(s1mono) xlabel(-24(4)24) legend(off) yscale(range(0.1 0.35)) ylabel(0.1(0.05)0.35) xline(0, lcolor(red))  ///
		ytitle("", size(medsmall))       /// 
	    xtitle("Date of birth relative to the cutoff", size(medsmall)) ///
		legend(off) ///
		title("Abitur (Kamila, missing as zero)", size(medsmall))  //
graph display, xsize(10) ysize(6)
graph save "${graphs}\acadt_filled_$date_full_`ds'_neu", replace
graph export "${graphs}\acadt_filled_$date_full_`ds'_neu.pdf", replace
restore

}
